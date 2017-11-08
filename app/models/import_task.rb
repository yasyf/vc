class ImportTask < ApplicationRecord
  MAX_DISTANCE = 2
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
    csv = ::CSV.foreach(filename, headers: false)
    headers = csv.first
    error! 'CSV is empty' and return unless headers.present?

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
      total: csv.count - 1,
      header_row: (headers if suggestions.present?),
    )
  end

  def enqueue_import!
    TargetInvestorImportJob.perform_later self.id
  end

  def import!
    ::CSV.foreach(filename) do |raw|
      increment! :imported
      next if header_row? && imported == 1
      import_row! raw
    end
    update! complete: true
  end

  private

  def import_row!(raw)
    row = raw
      .each_with_index
      .map { |x, i| [headers[i.to_s], x] if i.to_s.in?(headers) }
      .compact
      .to_h
      .with_indifferent_access
    name = (row[:name] || '').split(' ')
    email = Mail::Address.new(row[:email]).address rescue nil
    TargetInvestor.create!(
      founder: founder,
      first_name: row[:first_name] || name.first,
      last_name: row[:last_name] || name.drop(1).join(' '),
      firm_name: row[:firm],
      role: row[:role],
      email: email,
      note: row[:note]
    )
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    self.errored << raw
    nil
  end

  def error!(message, rows = [])
    update! error_message: message, errored: rows
  end

  def bucket_path
    "imports/#{founder_id}.csv"
  end

  def file_path
    Rails.root.join('tmp', 'imports', "#{founder_id}.csv")
  end
end
