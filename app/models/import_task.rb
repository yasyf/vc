class ImportTask < ApplicationRecord
  MAX_DISTANCE = 1
  MAX_ROWS = 300
  HEADERS = {
    first_name: ['First Name'],
    last_name: ['Last Name'],
    name: ['Full Name', 'Name'],
    role: %w(Title Role Position),
    email: ['Email', 'Email Address'],
    firm: %w(Firm Fund VC Company Organization),
    note: %w(Note Comment)
  }

  belongs_to :founder

  validates :founder, presence: true

  def self.storage
    @storage ||= GoogleCloud::Storage.new(ENV['GOOGLE_IMPORT_BUCKET'])
  end

  def self.headers
    HEADERS.transform_values(&:first)
  end

  def file=(file)
    self.class.storage.put(file.path, bucket_path)
  end

  def filename
    @filename ||= begin
      self.class.storage.get(bucket_path, file_path)
      file_path
    end
  end

  def enqueue_preview!
    TargetInvestorImportPreviewJob.perform_later self.id
  end

  def preview!
    csv = CSV.foreach(filename, headers: false, liberal_parsing: true).lazy
    headers = csv.first
    error! 'Your CSV is empty.' and return unless headers.present?

    total = Util.count_lines(filename) - 1
    error! "Your CSV is too large! There are #{total} rows, which is larger than the maximum of #{MAX_ROWS}." and return if total > MAX_ROWS

    suggestions = headers.each_with_index.with_object({}) do |(header, i), suggestions|
      next unless header.present?
      matches = HEADERS.each_with_object([]) do |(k, v), matches|
        next if k.in? suggestions.values
        v.each do |s|
          distance = Levenshtein.distance(s.downcase, header.downcase)
          matches.push([k, distance]) if distance <= MAX_DISTANCE
        end
      end
      suggestions[i] = matches.min_by(&:last).first if matches.present?
    end

    update!(
      headers: suggestions,
      samples: csv.drop(1).first(3),
      total:  total,
      header_row: (headers if suggestions.present?),
    )
  end

  def enqueue_import!
    TargetInvestorImportJob.perform_later self.id
  end

  def import!
    File.open(filename) do |f|
      f.each_line.lazy.drop(header_row? ? 1 : 0).each_with_index do |line, i|
        begin
          CSV.parse(line, liberal_parsing: true) do |raw|
            TargetInvestorImportRowJob.perform_later(self.id, raw)
          end
        rescue CSV::MalformedCSVError
          with_lock { self.reload.errored << i and save! }
          bump_imported!
        end
      end
    end
  end

  def import_row!(raw)
    row = raw
      .each_with_index
      .map { |x, i| [headers[i.to_s], x] if i.to_s.in?(headers) }
      .compact
      .to_h
      .with_indifferent_access
    name = (row[:name] || '').split(' ')
    email = Mail::Address.new(row[:email]).address rescue nil
    Founder.no_touching do
      TargetInvestor.create!(
        founder: founder,
        first_name: row[:first_name] || name.first,
        last_name: row[:last_name] || name.drop(1).join(' '),
        firm_name: row[:firm],
        role: row[:role],
        email: email,
        note: row[:note]
      )
    end
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    with_lock { self.reload.duplicates << raw and save! }
    save!
    nil
  ensure
    bump_imported!
    update! complete: true if self.reload.imported == self.total
  end

  private

  def bump_imported!
    self.class.increment_counter :imported, self.id
  end

  def error!(message)
    update! error_message: message
  end

  def bucket_path
    "imports/#{founder_id}.csv"
  end

  def file_path
    Rails.root.join('tmp', 'imports', "#{founder_id}.csv")
  end
end
