require 'test_helper'

class External::WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get external_root_url
    assert_response :success
  end

end
