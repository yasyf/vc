class ImportJob < ApplicationJob
  queue_as :default

  def perform(name, filename, headers)
    name.constantize.new(filename, headers).sync!
  end
end
