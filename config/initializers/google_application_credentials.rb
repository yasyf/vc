TEMP_DIR = 'tmp'
FILE_NAME = "#{TEMP_DIR}/google_application_credentials.json"

Rails.application.config.before_initialize do
  ENV['GOOGLE_APPLICATION_CREDENTIALS'] ||= FILE_NAME
  unless File.file?(ENV['GOOGLE_APPLICATION_CREDENTIALS'])
    FileUtils.mkdir_p TEMP_DIR
    decoded = Base64.decode64(ENV['GOOGLE_CREDENTIAL_BLOB'])
    File.write FILE_NAME, decoded
  end
end