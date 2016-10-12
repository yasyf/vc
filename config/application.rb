require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Drfvote
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.eager_load_paths << Rails.root.join('lib')
    config.time_zone = 'Eastern Time (US & Canada)'

    %w(teams overrides).each do |name|
      result = YAML.load(ERB.new(File.read(Rails.root.join('config', "#{name}.yml"))).result)
      config.send("#{name}=", result)
    end
  end
end
