require 'test_helper'

class Manage::ReportsControllerTest < ActionController::TestCase
  test "heard_about_us" do
    sign_in users(:anne)
    get :heard_about_us
    assert_response :success
  end
end
