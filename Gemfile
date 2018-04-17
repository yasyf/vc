source 'https://rubygems.org'
ruby '2.5.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.5'
# Use postgresql as the database for Active Record
gem 'pg', '< 1.0.0'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

gem 'webpacker'
gem 'webpacker-react', '~> 0.3.2'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-turbolinks'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'ruby-trello'
gem 'chronic'
gem 'slack-ruby-client'
gem 'picky'
gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'twitter-bootstrap-rails'
gem 'workers'
gem 'ox', '>= 2.1.2'
gem 'premailer-rails'
gem 'httparty'
gem 'googleauth'
gem 'google-api-client'
gem 'levenshtein-ffi', require: 'levenshtein'
gem 'sentry-raven'
gem 'roo'
gem 'lograge'
gem 'twitter', '~> 6.2.x'
gem 'redis'
gem 'redis-namespace'
gem 'redis-rails'
gem 'sidekiq'
gem 'zhong'
gem 'textacular', '~> 5.0'
gem 'gon'
gem 'retriable', '~> 3.1.1'
gem 'metainspector'
gem 'feedjira'
gem 'google-cloud-language', '0.27.1'
gem 'google-cloud-storage'
gem 'google-cloud-pubsub'
gem 'gender_detector'
gem 'curb', github: 'taf2/curb'
gem 'clearbit'
gem 'googlemaps-services'
gem 'sinatra', '~> 2.0', require: false
gem 'rack-timeout'
gem 'ruby-readability'
gem 'countries', '~> 2.1.4', :require => 'countries/global'
gem 'execjs'
gem 'geocoder'
gem 'redcarpet'
gem 'activerecord-precount'
gem 'sitemap_generator'
gem 'parallel'
gem 'addressable'
gem 'browser'
gem 'neography'
gem 'email_reply_parser'
gem 'prop'
gem 'pghero'
gem 'pg_query', '>= 0.9.0'
gem 'scenic'
gem 'grpc', '1.11.0' # tmp fix for grpc#13908
gem 'mixpanel-ruby'

group :test do
  gem 'minitest', '~> 5.11.2'
  gem 'webmock'
end

group :production do
  gem 'puma'
  gem 'dalli'
  gem 'connection_pool'
  install_if -> { RUBY_PLATFORM =~ /linux/ } do
    gem 'hive_geoip2'
  end
  gem 'scout_apm', '~> 3.0.pre23'
  gem 'puma_worker_killer', require: false
end

group :development, :staging do
  gem 'letter_opener_web'
end

group :development, :staging, :test do
  gem 'dotenv-rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'awesome_print'
  gem 'guard-rspec', require: false
  gem 'spring-commands-rspec'
  gem 'bullet'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.6'
  gem 'factory_bot_rails'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
