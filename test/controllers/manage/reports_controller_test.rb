require 'test_helper'

class Manage::ReportsControllerTest < ActionController::TestCase
  test "endpoints" do
    endpoints = [
      :heard_about_us, :active_projects_by_status,
      :new_projects_by_month, :new_finishers_by_month
    ]
    sign_in users(:admin)

    endpoints.each do |endpoint|
      get endpoint
      assert_response :success
    end
  end
end
