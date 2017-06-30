require 'test_helper'

class Internal::CompaniesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :found
  end

end
