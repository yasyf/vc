require 'google/apis/drive_v3'

module GoogleApi
  class Drive < Base
    include Concerns::Cacheable

    SCOPES = ['https://www.googleapis.com/auth/drive']

    def initialize
      @drive = Google::Apis::DriveV3::DriveService.new
      @drive.authorization = authorization
    end

    def find(term, fields = 'files/webViewLink')
      key_cached({ term: term, fields: fields }) { raw_find(term, fields) }
    end

    def list(folder_id, fields = 'files(id,modifiedTime,name)')
      @drive.list_files(q: "'#{folder_id}' in parents", fields: fields).files
    end

    def export(file_id, mime_type)
      @drive.export_file file_id, mime_type, download_dest: StringIO.new
    end

    private

    def cache_options
      { expires_in: jitter(1, :day) }
    end

    def raw_find(term, fields)
      @drive.list_files(q: "name = '#{term}'", order_by: 'createdTime desc', fields: fields).files.first
    rescue Google::Apis::ClientError
      nil
    end

    def base_cache_key
      "google_api/drive"
    end
  end
end
