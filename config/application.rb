require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

CONFIGS = %w(teams overrides pg_guc)
APPS = %w(drfvote vcwiz)

module Drfvote
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.load_defaults 5.0
    config.active_record.belongs_to_required_by_default = false

    config.eager_load_paths << Rails.root.join('lib')
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.active_record.schema_format = :sql
    config.active_record.cache_timestamp_format = :nsec
    config.exceptions_app = self.routes

    config.generators do |g|
      g.test_framework :rspec
    end

    CONFIGS.each do |name|
      result = YAML.load(ERB.new(File.read(Rails.root.join('config', "#{name}.yml"))).result)
      config.send("#{name}=", result.with_indifferent_access)
    end

    APPS.each do |name|
      define_method("#{name}?") { Rails.env.test? || ENV['HEROKU_APP_NAME'].start_with?(name) }
    end

    if vcwiz?
      REDIS_CACHE = ActiveSupport::Cache.lookup_store :redis_store, ENV['REDIS_CACHE_URL'], { expires_in: 1.week }
      REDIS_PROP_CACHE = ActiveSupport::Cache.lookup_store :redis_store, ENV['REDIS_PROP_CACHE_URL'], { expires_in: 1.day }

      define_method(:redis_cache) { REDIS_CACHE }
      define_method(:redis_prop_cache) { REDIS_PROP_CACHE }
    end
  end
end
