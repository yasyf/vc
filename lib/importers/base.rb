require 'csv'
require 'open-uri'

module Importers
  class Base
    private
    def url?(filename)
      filename =~ /\A#{URI::regexp(%w(ftp http https))}\z/
    end

    def save(input)
      file = Tempfile.new 'csv'
      stream = input.is_a?(StringIO) ? input.tap(&:rewind) : open(input)
      IO.copy_stream stream, file.path
      file.path
    end
  end
end
