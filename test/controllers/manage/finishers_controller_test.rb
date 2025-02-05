require "test_helper"

class Manage::FinishersControllerTest < ActionController::TestCase
  setup do
    @user = users(:admin)
    assert(@user.can_manage?)
  end

  test "search requires login" do
    get :search
    assert_redirected_to new_user_registration_path
  end

  test "search requires can_manage? access" do
    @user_without_manager = users(:basic)
    refute(@user_without_manager.can_manage?)

    sign_in @user_without_manager
    get :search
    assert_redirected_to root_path
  end

  test "search with no parameters" do
    sign_in @user
    get :search
    assert_response :success
    assert_equal([], JSON.parse(response.body))
  end

  test "search with no matches" do
    sign_in @user
    get :search, params: { term: "xyz" }
    assert_response :success
    assert_equal([], JSON.parse(response.body))
  end

  test "search with parameters returning one match" do
    match_finisher = finishers(:knitter)
    sign_in @user
    get :search, params: { term: "fran" }
    assert_response :success
    assert_equal([{ "id" => match_finisher.id, "name" => match_finisher.chosen_name }], JSON.parse(response.body))
  end

  test "search with parameters returning multiple matches" do
    match_finishers = [finishers(:crocheter), finishers(:knitter)]
    sign_in @user
    get :search, params: { term: "y" }
    assert_response :success
    assert_equal(match_finishers.map { |f| { "id" => f.id, "name" => f.chosen_name } },
                 JSON.parse(response.body))
  end

  test "does not allow SQL injection" do
    sign_in @user
    get :search, params: { term: "f;' DROP TABLE finishers; --" }
    assert_response :success
    assert_equal([], JSON.parse(response.body))
    assert(Finisher.count > 0)
  end
end
