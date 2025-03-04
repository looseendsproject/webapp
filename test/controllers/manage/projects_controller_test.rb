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
      assert (projects[0].created_at > projects[1].created_at)
    end

    test "index sort by created_at desc returns results in new order" do
      sign_in @user
      get "/manage/projects?sort=created_at+asc"
      projects = assigns(:projects)
      assert (projects[0].created_at < projects[1].created_at)
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

    private

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
