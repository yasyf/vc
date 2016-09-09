require 'csv'
require 'open-uri'

module Importers::Folders
  class Nyc < Importers::VotingBase
    FILENAME_REGEX = /(?:\d{1,2}\/\d{1,2} )?(.+)/
    MIME_TYPE = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    COLUMNS = [:date, :email, :name, :team, :market, :product, :fit, :overall, :reason]
    HEADERS = {
      date: 'Timestamp',
      email: 'Username',
      product: 'Product',
      market: 'Market',
      team: 'Team',
      fit: 'Fit',
      overall: 'Overall',
      reason: 'Reasoning',
      name: 'Name',
    }
    INVERTED_HEADERS = HEADERS.invert

    def initialize(folder_id)
      @folder_id = folder_id
      @drive = GoogleApi::Drive.new
    end

    def sync!
      @drive.list(@folder_id).each(&method(:process_file!))
    end

    private

    def team
      Team.nyc
    end

    def extract_new_style_rows(sheet)
      parsed = begin
        sheet.parse(HEADERS)
      rescue Roo::HeaderRowNotFoundError
        sheet.parse.select { |row| row.compact.present? }.map { |row| COLUMNS.zip(row).to_h }
      end
    end

    def extract_old_style_rows(sheet)
      rows = sheet.parse.select { |row| row.compact.present? }
      headers = rows.first.map.with_index do |cell, i|
        (!cell.present? && i == 0) ? :name : INVERTED_HEADERS[cell]
      end
      rows.drop(1).map.with_index do |row, i|
        headers.zip(row).reject { |h, r| h.blank? }.to_h
      end
    end

    def parse_rows(sheets)
      old_style_rows = extract_old_style_rows(sheets.sheet(0))
      if sheets.count == 1
        old_style_rows
      else
        extract_new_style_rows(sheets.sheet(1)) + old_style_rows
      end
    end

    def process_file!(file)
      output = @drive.export file.id, MIME_TYPE
      path = save output
      begin
        sheets = Roo::Spreadsheet.open(path, extension: :xlsx)
      rescue
        return
      end

      emails = if (index = sheets.sheets.index('Names')).present?
        sheets.sheet(index).parse.drop(1).map { |row| row.first(2).reverse }.to_h
      else
        {}
      end

      extract_email = ->(name) { emails[name] || team.users.where('cached_name ILIKE ?', "#{name}%").first&.username }

      parse_rows(sheets).each do |parsed|
        next if parsed[:date] == HEADERS[:date]
        parsed[:date] ||= file.modified_time
        parsed[:email] ||= extract_email.call(parsed[:name]) if parsed[:name].present?
        next unless parsed[:email].present?
        parsed[:overall] = nil if parsed[:overall].is_a?(String)
        parsed[:company] = FILENAME_REGEX.match(file.name)[1]
        import! parsed
      end
    end
  end
end
