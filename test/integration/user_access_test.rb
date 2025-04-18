require "test_helper"

class UserAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "landing page loads" do
    get "/"

    assert_response :success
  end

  test "user/registration loads" do
    get "/users/sign_up"

    assert_response :success
  end

  test "/finisher for unauthed request redirects" do
    get "/finisher"

    assert_redirected_to new_user_session_path
  end

  test "finisher can view profile" do
    sign_in users(:finisher)
    get "/finisher"

    assert_response :success
  end

  test "Sign in redirect from project redirects back" do
    project = projects(:one)
    user = project.user
    user.password = "password"
    user.save!
    get "/projects/#{project.id}"

    assert_redirected_to new_user_session_path
    follow_redirect!

    assert_response :success
    assert_select "h1", { text: "Sign in" }

    post "/users/sign_in", params: { user: { email: user.email, password: "password" } }

    assert_redirected_to "/projects/#{project.id}"
  end
end
