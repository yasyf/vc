ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  Rails.configuration.teams.keys.each do |name|
    Team.where(name: name).first_or_create!
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    sign_in User.first
  end
end
