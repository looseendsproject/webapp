require 'test_helper'

class Manage::FinishersControllerTest < ActionController::TestCase
  setup do
    @user = users(:admin)
    assert(@user.can_manage?)
  end

  test 'search requires login' do
    get :search
    assert_redirected_to new_user_registration_path
  end

  test 'search requires can_manage? access' do
    @user_without_manager = users(:basic)
    refute(@user_without_manager.can_manage?)

    sign_in @user_without_manager
    get :search
    assert_redirected_to root_path
  end

  test 'search with no parameters' do
    sign_in @user
    get :search
    assert_response :success
    assert_equal([], JSON.parse(response.body))
  end

  test 'search with no matches' do
    sign_in @user
    get :search, params: { term: 'xyz' }
    assert_response :success
    assert_equal([], JSON.parse(response.body))
  end

  test 'search with parameters returning one match' do
    sign_in @user
    get :search, params: { term: 'fran' }
    assert_response :success
    assert_equal([{"id"=>2, "name"=>"Franny"}], JSON.parse(response.body))
  end

  test 'search with parameters returning multiple matches' do
    sign_in @user
    get :search, params: { term: 'f' }
    assert_response :success
    assert_equal([{"id"=>2, "name"=>"Franny"}], JSON.parse(response.body))
  end

  test 'does not allow SQL injection' do
    sign_in @user
    get :search, params: { term: 'f;\' DROP TABLE finishers; --' }
    assert_response :success
    assert_equal([], JSON.parse(response.body))
    assert(Finisher.count > 0)
  end
end