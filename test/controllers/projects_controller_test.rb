# frozen_string_literal: true

require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
  end

  test "should create project without image renders new page" do
    sign_in @project.user
    post :create, params: {
      project: {
        name: "New Project",
        phone_number: "1234561890",
        description: "Description here",
        craft_type: "Knitting"
      }
    }

    assert_response :success
  end

  test "should create project with image" do
    sign_in @project.user
    assert_difference("Project.count") do
      post :create, params: {
        project: {
          name: "New Project",
          phone_number: "1234561890",
          description: "Description here",
          craft_type: "Knitting",
          append_project_images: [fixture_file_upload("test.jpg")]
        }
      }
    end

    new_project = Project.find_by(name: "New Project")
    assert_not_nil new_project
    assert_redirected_to project_path(new_project)
  end

  test "should update project" do
    sign_in @project.user
    patch :update, params: {
      id: @project,
      project: {
        name: "Updated Name"
      }
    }
    assert_redirected_to project_path(@project)
    assert_equal "Updated Name", @project.reload.name
  end
end
