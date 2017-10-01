require 'google/cloud/storage'

module GoogleCloud
  class Storage
    def initialize(bucket)
      @bucket = self.class.client.bucket bucket
    end

    def get(path, fname)
      @bucket.file(path).download(fname)
    end

    def put(fname, path)
      @bucket.create_file(fname, path)
    end

    def self.client
      @client ||= ::Google::Cloud::Storage.new project: ENV['GC_PROJECT_ID']
    end
  end
end
