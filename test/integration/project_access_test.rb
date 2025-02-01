require 'test_helper'

class ProjectAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @one = projects :one
    @two = projects :two
    refute_equal("Tests rely on different users", @one.user_id, @two.user_id)
  end

  test 'project page logged out' do
    get '/projects/1'
    assert_redirected_to '/'
  end

  test 'project page logged in as owner' do
    sign_in @one.user
    get '/projects/1'
    assert_response :success
  end

  test 'project page logged in as non-owner' do
    sign_in @two.user
    get '/projects/1'
     assert_redirected_to '/'
  end
end