
require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  def setup
    @user = users(:bob)
  end

  test "should get show, logged out" do
    get :show
    assert_response :success
  end

  test "should get show, logged in" do
    sign_in @user
    get :show
    assert_response :success
  end
end