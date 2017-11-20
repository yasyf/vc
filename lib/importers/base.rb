require 'csv'
require 'open-uri'

module Importers
  class Base
    HEADER_DEFAULTS = {}

    attr_reader :filename

    def initialize(filename, headers = {})
      @filename = url?(filename) ? save(filename) : filename
      @headers = headers.with_indifferent_access.slice(*self.class::HEADER_DEFAULTS.keys).reverse_merge(self.class::HEADER_DEFAULTS)
    end

    def preprocess(row)
      @headers.map { |h,s| [h, row[s].try(:strip)] }.to_h.compact.with_indifferent_access
    end

    def sync!(async: true)
      ::CSV.foreach(@filename, headers: true) do |row|
        parsed = preprocess(row)
        if async
          ImportRowJob.perform_later(self.class.name, parsed)
        else
          ImportRowJob.perform_now(self.class.name, parsed)
        end
      end
    end

    def self.sync_later(filename, headers = {})
      ImportJob.perform_later(self.name, filename, headers)
    end

    private

    def url?(filename)
      filename =~ /\A#{URI::regexp(%w(ftp http https))}\z/
    end

    def file?(file)
      file.respond_to? :read
    end

    def save(input)
      file = Tempfile.new 'csv'
      stream = input.is_a?(StringIO) ? input.tap(&:rewind) : open(input)
      IO.copy_stream stream, file.path
      file.path
    end
  end
end
