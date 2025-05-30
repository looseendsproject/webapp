# frozen_string_literal: true

require "test_helper"

class ProjectsControllerTest < ActionController::TestCase
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

    assert_select ".error_message li", { text: "Project images can't be blank", count: 1 }
  end

  test "should fail to create project with tiny image" do
    sign_in @project.user
    post :create, params: {
      project: {
        name: "New Project",
        phone_number: "1234561890",
        description: "Description here",
        craft_type: "Knitting",
        append_project_images: [fixture_file_upload("tiny.jpg")]
      }
    }

    assert_match("Project images file size must be greater than or equal to 5 KB", response.body)
  end

  test "should create project with image" do
    sign_in @project.user
    assert_difference("Project.count") do
      post :create, params: {
        project: {
          name: "New Project",
          phone_number: "1234567890",
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

  test "should fail to create on invalid phone with image" do
    sign_in @project.user
    post :create, params: {
      project: {
        name: "New Project",
        phone_number: "123", # too short
        description: "Description here",
        craft_type: "Knitting",
        append_project_images: [fixture_file_upload("test.jpg")],
        append_crafter_images: [fixture_file_upload("test.jpg")]
      }
    }

    assert_response :success
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

  test "should not include the manager-only material_brand field" do
    @project.update!(material_brand: "brandname")

    sign_in @project.user
    get :show, params: { id: @project }

    assert_no_match(/brandname/, response.body)
  end

  test "should show terms of service" do
    sign_in users(:project_owner)
    get :new

    assert_select "h2", { text: "Terms of Service" }
  end

  test "should not show terms of service" do
    @project_owner = users(:project_owner)
    sign_in @project_owner
    get :edit_project, params: { id: @project_owner.projects.first.to_param }

    assert_select "h5", { text: "Terms of Service", count: 0 }
  end

  test "should allow editing of submitter details" do
    @project_owner = users(:project_owner)
    sign_in @project_owner
    get :edit_address, params: { id: @project_owner.projects.first.to_param }

    assert_select "h1", { text: "Your Details", count: 1 }
    assert_select "input", { name: :phone_number }
  end
end
