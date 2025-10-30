require 'test_helper'

class Manage::ReportsControllerTest < ActionController::TestCase

  def setup
    sign_in users(:admin)
  end

  test "index" do
    get :index
    assert_response :success
  end

  test "endpoints" do
    [
      :heard_about_us, :active_projects_by_status,
      :new_projects_by_month, :new_finishers_by_month,
      :project_counts
    ].each do |endpoint|
      get endpoint
      assert_response :success
    end
  end

  test "country counts JSON" do
    get :project_countries, format: :json

    assert_response :success
    project_counts = JSON.parse(@response.body)
    assert_kind_of(Hash, project_counts)

    get :finisher_countries, format: :json

    assert_response :success
    finisher_counts = JSON.parse(@response.body)
    assert_kind_of(Hash, finisher_counts)
  end

  test "country counts CSV" do
    get :project_countries, format: :csv

    assert_response :success
    assert_equal "text/csv", @response.content_type
    assert_includes @response.body, "Country,Count"

    get :finisher_countries, format: :csv

    assert_response :success
    assert_equal "text/csv", @response.content_type
    assert_includes @response.body, "Country,Count"
  end
end
