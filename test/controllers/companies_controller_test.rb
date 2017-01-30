require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :found
  end

end
