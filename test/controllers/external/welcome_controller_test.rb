require 'test_helper'

class External::WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get external_root_url
    assert_redirected_to external_vcfinder_root_url
  end

end
