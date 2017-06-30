require 'test_helper'

class External::WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get external_welcome_index_url
    assert_response :success
  end

end
