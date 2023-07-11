require 'test_helper'

class ProjectAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @one = projects :one
    @two = projects :two
  end

  # test 'project page logged out' do
  #   get '/projects/1'
  #   assert_redirected_to '/'
  # end

  test 'project page logged in' do
    sign_in users(:bob)

    get '/projects/1'
    assert_response :success
  end
end