# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get show, logged out" do
    get :show
    assert_response :success
  end

  test "should get show, logged in" do
    sign_in users(:basic)
    get :show
    assert_response :success
  end

  test "should show 'Finisher Profile' link in the header for a finisher" do
    sign_in users(:finisher)
    get :show
    assert_select "header a", { text: "Finisher Profile" }
    assert_select "header a", { text: "Manage", count: 0 }
    assert_select "header a", { text: "Admin", count: 0 }
  end

  test "should show 'Manage' link in the header for a manager" do
    sign_in users(:manager)
    get :show
    assert_select "header a", { text: "Manage" }
    assert_select "header a", { text: "Admin", count: 0 }
  end

  test "should show 'Admin' link in the header for an Admin" do
    sign_in users(:admin)
    get :show
    assert_select "header a", { text: "Manage" }
    assert_select "header a", { text: "Admin" }
  end

  test "should show Projects if user has projects" do
    sign_in users(:project_owner)
    get :show
    assert_select "#projects", { count: 1 }
    assert_select "#projects a", { text: "Project Title One", count: 1 }
  end

  test "should not show Projects if user has no projects" do
    sign_in users(:basic)
    get :show
    assert_select "#projects", { count: 0 }
  end
end
