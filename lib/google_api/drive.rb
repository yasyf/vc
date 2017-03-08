require 'google/apis/drive_v3'

module GoogleApi
  class Drive < Base
    include Concerns::Cacheable

    SCOPES = ['https://www.googleapis.com/auth/drive']

    def initialize(user)
      @user = user
      @drive = Google::Apis::DriveV3::DriveService.new
      @drive.authorization = authorization
    end

    def create(name, mime_type, upload_source, parents = [], file_mime_type = nil, fields = 'id,webViewLink')
      file_mime_type ||= Rack::Mime.mime_type ".#{upload_source.split('.').last}" if upload_source.is_a?(String)
      metadata = { name: name, mime_type: mime_type, parents: Array.wrap(parents) }
      @drive.create_file metadata, fields: fields, upload_source: upload_source, content_type: file_mime_type
    end

    def find(term, fields = 'files/id,files/webViewLink', in_folders: [], excludes: [], cache: true)
      components = ["name contains '#{term}'"]
      components << Array.wrap(in_folders).map { |folder| "'#{folder}' in parents" }.join(' or ') if in_folders.present?
      components << Array.wrap(excludes).map { |folder| "not '#{folder}' in parents" }.join(' or ') if excludes.present?
      query = components.map { |comp| "(#{comp})" }.join(' and ')
      key_cached({ query: query, fields: fields }, cache ? {} : { force: true }) { raw_find(query, fields) }
    end

    def list(folder_id, fields = 'files(id,modifiedTime,name)')
      @drive.list_files(q: "'#{folder_id}' in parents", fields: fields).files
    end

    def export(file_id, mime_type)
      @drive.export_file file_id, mime_type, download_dest: StringIO.new
    end

    def append(file_id, mime_type, data)
      contents = export(file_id, mime_type).string + data
      @drive.update_file file_id, upload_source: StringIO.new(contents)
    end

    private

    def cache_options
      { expires_in: jitter(1, :day) }
    end

    def raw_find(query, fields)
      @drive.list_files(q: query, order_by: 'createdTime desc', fields: fields).files.first
    rescue Google::Apis::ClientError
      nil
    end

    def base_cache_key
      "google_api/drive"
    end
  end
end
