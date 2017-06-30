require 'test_helper'

class Internal::WelcomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :found
  end

end
