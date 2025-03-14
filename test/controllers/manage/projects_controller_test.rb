# frozen_string_literal: true

require "test_helper"

module Manage
  class ProjectsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:admin)

      assert_predicate(@user, :can_manage?)
      @project = projects(:one)
    end

    test "index requires login" do
      get "/manage/projects"

      assert_redirected_to new_user_registration_path
    end

    test "index requires can_manage? access" do
      @user_without_manager = users(:basic)

      assert_not_predicate(@user_without_manager, :can_manage?)

      sign_in @user_without_manager
      get "/manage/projects"

      assert_redirected_to root_path
    end

    test "index loads" do
      sign_in @user
      get "/manage/projects"

      assert_response :success
    end

    test "index default sorts by created_at" do
      sign_in @user
      get "/manage/projects"
      projects = assigns(:projects)

      assert_operator(projects[0].created_at, :>, projects[1].created_at)
    end

    test "index sort by created_at desc returns results in new order" do
      sign_in @user
      get "/manage/projects?sort=created_at+asc"
      projects = assigns(:projects)

      assert_operator(projects[0].created_at, :<, projects[1].created_at)
    end

    test "CSV export metadata" do
      sign_in @user

      get "/manage/projects.csv"

      assert_response :success
      assert_equal("text/csv", response.media_type)
      assert_predicate(response.headers["Content-Disposition"], :present?)
    end

    test "CSV export contents" do
      sign_in @user

      get "/manage/projects.csv"

      assert_response :success
      assert_predicate(response.body, :present?)
      %w[Id Name].each do |header|
        assert_includes(response.body, header)
      end
    end

    test "new project page loads" do
      sign_in @user
      get "/manage/projects/new"

      assert_response :success
    end

    test "show loads" do
      sign_in @user
      get "/manage/projects/#{@project.id}"

      assert_response :success
    end

    test "edit loads" do
      sign_in @user
      get "/manage/projects/#{@project.id}/edit"

      assert_response :success
    end

    test "update alters project" do
      @project.name = "New Name"

      sign_in @user
      patch "/manage/projects/#{@project.id}", params: { project: { name: "New Name" } }

      assert_redirected_to manage_project_path(@project)
      assert_equal("New Name", @project.reload.name)
    end

    test "create with incomplete params renders page" do
      sign_in @user
      post "/manage/projects", params: { project: { name: "Lacking Details" } }

      assert_response :success
    end

    test "create with complete params creates project" do
      project_params = new_project_params
      sign_in @user
      assert_difference("Project.count") do
        post "/manage/projects", params: { project: project_params }
      end
      assert_redirected_to manage_project_path(Project.last)
    end

    test "destroy removes project" do
      sign_in @user
      assert_difference("Project.count", -1) do
        delete "/manage/projects/#{@project.id}"
      end
      assert_redirected_to manage_projects_path
      assert_not(Project.exists?(@project.id))
    end

    test "search by text" do # rubocop:disable Minitest/MultipleAssertions
      result = create_search_project

      assert_search_results([result], search: "Search Project")
      assert_search_results([result], search: '"Search Project"')
      assert_search_results([result], search: '"Specific Description"')
      assert_search_results([result], search: "knitting")
      assert_search_results([result], search: "yak")
      assert_search_results([result], search: "Anytown")
      assert_search_results([result], search: "WA")

      assert_search_no_results(search: "NOT_A_MATCHING_STRING")
    end

    test "search by project boolean attributes" do
      result = create_search_project
      # Required for some attributes
      result.update!(group_manager: Finisher.first, press_outlet: "TCM", press_region: "US")

      Project::BOOLEAN_ATTRIBUTES.each do |attribute|
        result.update!(attribute => true)

        assert_search_results([result], attribute => "true")
        assert_search_no_results(attribute => "false")
        # Reset the attribute for the next iteration
        result.update!(attribute => false)
      end
    end

    test "search by manager_id" do
      result = create_search_project
      result.update!(manager: @user)

      assert_search_results([result], manager_id: @user.id)
      assert_search_no_results(manager_id: "0")
    end

    test "search by status" do
      result = create_search_project
      result.update!(status: "proposed")

      assert_search_results([result], status: "proposed")
      assert_search_no_results(status: "drafted")
    end

    test "search by assigned" do
      result = create_search_project
      result.assignments.create!(user: @user, finisher: Finisher.first)

      assert_search_results([result], assigned: nil)
      assert_search_results([result], assigned: "true")
      assert_search_no_results(assigned: "false")
    end

    test "search is paginated" do
      11.times do
        create_search_project
      end

      sign_in @user
      get "/manage/projects", params: { page: 1, per_page: 10 }

      assert_response :success
      assert_select "div.pagination"
    end

    test "search view=list returns list view" do
      create_search_project
      sign_in @user
      get "/manage/projects", params: { view: "list" }

      assert_response :success
      assert_select "table.project-table"
    end

    private

    def create_search_project # rubocop:disable Metrics/MethodLength
      Project.create!(
        name: "Search Project",
        description: "Search Project Specific Description",
        craft_type: "knitting I think",
        material_type: "yak wool",
        street: "123 Main St",
        street_2: "",
        city: "Anytown",
        state: "WA",
        postal_code: "12345",
        country: "US",
        phone_number: "555-555-5555",
        project_images: [fixture_file_upload("test.jpg")],
        user: @user
      )
    end

    def assert_search_results(projects, params)
      sign_in @user
      get "/manage/projects", params: params

      assert_response :success
      projects.each do |project|
        assert_select "a[href=?]", manage_project_path(project)
      end
    end

    def assert_search_no_results(params)
      sign_in @user
      get "/manage/projects", params: params

      assert_response :success
      assert_select "a[href=?]", %r{/manage/projects/\d+}, count: 0
    end

    def new_project_params
      project_params = @project.attributes.dup
      %w[id user_id created_at updated_at latitude longitude country].each do |key|
        project_params.delete(key)
      end
      project_params["name"] = "New Project Name"
      project_params["append_project_images"] = [fixture_file_upload("test.jpg")]
      project_params
    end
  end
end
