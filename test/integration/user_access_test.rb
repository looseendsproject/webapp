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
end
