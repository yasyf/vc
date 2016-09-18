require 'csv'
require 'open-uri'

module Importers::Folders
  class BaseFolder < Importers::VotingBase
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
      new_style_rows = begin
        sheets.count == 1 ? [] : extract_new_style_rows(sheets.sheet(1))
      rescue ArgumentError
        []
      end
      old_style_rows + new_style_rows
    end

    def parse_filename(filename)
      Array.wrap(self.class::FILENAME_REGEX).each do |regex|
        matches = regex.match(filename)
        return matches[1] if matches.present?
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

      parse_rows(sheets).each do |parsed|
        next if parsed[:date] == HEADERS[:date]
        parsed[:date] ||= file.modified_time
        parsed[:email] ||= extract_email(parsed[:name], emails) if parsed[:name].present?
        next unless parsed[:email].present?
        parsed[:company] = parse_filename file.name
        import! parsed
      end
    end
  end
end
