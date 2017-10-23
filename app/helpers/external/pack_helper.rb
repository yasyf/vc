module External::PackHelper
  def common_js
    File.read(Rails.root.join('app', 'javascript', 'packs', 'external', 'common.js'))
  end

  module_function :common_js
end
