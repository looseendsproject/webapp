require 'test_helper'

class Manage::ReportsControllerTest < ActionController::TestCase

  def setup
    sign_in users(:admin)
  end

  test "index" do
    get :index
    assert_response :success
  end

  test "endpoints" do
    [
      :heard_about_us, :active_projects_by_status,
      :new_projects_by_month, :new_finishers_by_month
    ].each do |endpoint|
      get endpoint
      assert_response :success
    end
  end
end
