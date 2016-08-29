require 'google/apis/drive_v3'

module GoogleApi
  class Drive < Base
    SCOPES = ['https://www.googleapis.com/auth/drive']

    def initialize
      @drive = Google::Apis::DriveV3::DriveService.new
      @drive.authorization = authorization
    end

    def find(term, fields = 'files/webViewLink')
      @drive.list_files(q: "name = '#{term}'", fields: fields).files.first
    rescue Google::Apis::ClientError
      nil
    end
  end
end
