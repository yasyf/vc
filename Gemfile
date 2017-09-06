source 'https://rubygems.org'
ruby '2.4.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.2'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'webpacker'
gem 'webpacker-react', '~> 0.3.1'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-turbolinks'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'ruby-trello'
gem 'chronic'
gem 'picky'
gem 'slack-ruby-client'
gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'twitter-bootstrap-rails'
gem 'workers'
gem 'nokogiri'
gem 'premailer-rails'
gem 'httparty'
gem 'googleauth'
gem 'google-api-client'
gem 'levenshtein-ffi', require: 'levenshtein'
gem 'sentry-raven'
gem 'roo'
gem 'lograge'
gem 'twitter'
gem 'redis'
gem 'redis-namespace'
gem 'sidekiq'
gem 'clockwork'
gem 'retries'
gem 'textacular'
gem 'gon'
gem 'retriable', '~> 3.0'
gem 'metainspector'
gem 'feedjira'
gem 'google-cloud-language'

group :test do
  gem 'minitest', '~> 5.10', '!= 5.10.2'
  gem 'webmock'
end

group :production do
  gem 'rails_12factor'
  gem 'puma'
  gem 'dalli'
  gem 'connection_pool'
  gem 'scout_apm'
end

group :development, :staging do
  gem 'letter_opener_web'
end

group :development, :staging, :test do
  gem 'dotenv-rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.6'
  gem 'factory_girl_rails'
  gem 'guard-rspec', require: false
  gem 'rb-fsevent', '0.10.2'
  gem 'spring-commands-rspec'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
