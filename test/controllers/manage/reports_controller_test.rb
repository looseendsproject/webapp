require 'test_helper'

class Manage::ReportsControllerTest < ActionController::TestCase
  test "heard_about_us" do

    all_routes = [
      :heard_about_us, :active_projects_by_status,
      :new_projects_by_month, :new_finishers_by_month
    ]

    sign_in users(:admin)

    all_routes.each do |route|
      get route
      assert_response :success
    end
  end
end
