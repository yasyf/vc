require 'google/cloud/storage'

module GoogleCloud
  class Storage
    def initialize(bucket)
      @bucket = self.class.client.bucket bucket
    end

    def get(path, fname)
      FileUtils.mkdir_p File.dirname(fname)
      @bucket.file(path).download(fname.try(:to_path) || fname)
    end

    def delete(path)
      @bucket.file(path).delete
    end

    def put(fname, path)
      @bucket.create_file(fname.try(:to_path) || fname, path)
    end

    def self.client
      @client ||= ::Google::Cloud::Storage.new project: ENV['GC_PROJECT_ID']
    end
  end
end
