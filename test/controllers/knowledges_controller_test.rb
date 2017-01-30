require 'test_helper'

class KnowledgesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :found
  end

end
