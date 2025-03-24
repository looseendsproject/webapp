require 'test_helper'

class UserAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'landing page loads' do
    get '/'
    assert_response :success
  end

  test 'user/registration loads' do
    get '/users/sign_up'
    assert_response :success
  end

  test '/finisher for unauthed request redirects' do
    get '/finisher'
    assert_redirected_to :root
  end

  test "finisher can view profile" do
    sign_in users(:finisher)
    get '/finisher'
    assert_response :success
  end
end
