# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionController::TestCase
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

  test "should show project prompt if user has projects" do
    sign_in users(:basic)
    get :show

    assert_select "h4", { text: "Submit a Project" }
    assert_select "#projects", { count: 0 }
  end

  test "should show finisher prompt if the user has no finisher" do
    sign_in users(:new)
    get :show

    assert_select "h4", { text: "Volunteer as a Finisher" }
  end

  test "should show finisher incomplete if the user has incomplete finisher" do
    sign_in users(:basic)
    get :show

    assert_select "h4", { text: "Finisher" }
  end

  test "should show finisher congrats if the user has finisher" do
    user = users(:finisher)
    user.finisher.update_attribute(:has_completed_profile, true) # rubocop:disable Rails/SkipsModelValidations

    sign_in user
    get :show

    assert_select "h4", { text: "You're a Finisher" }
  end
end
