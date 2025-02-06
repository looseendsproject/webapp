require 'test_helper'

class ManagerAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'manager dashboard logged out' do
    get '/manage/dashboard'
    assert_redirected_to '/users/sign_up'
  end

  test 'manager dashboard logged in normal' do
    sign_in users(:basic)
    get '/manage/dashboard'
    assert_redirected_to '/'
  end

  test 'manager dashboard logged in manager' do
    sign_in users(:manager)
    get '/manage/dashboard'
    assert_response :success
  end

  test 'manager dashboard logged in admin' do
    sign_in users(:admin)
    get '/manage/dashboard'
    assert_response :success
  end

end