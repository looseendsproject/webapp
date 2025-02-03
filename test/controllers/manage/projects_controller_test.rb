require 'test_helper'

class Manage::ProjectsControllerTest < ActionController::TestCase
  setup do
    @user = users(:anne)
    assert(@user.can_manage?)
    @project = projects(:one)
  end

  test 'index requires login' do
    get :index
    assert_redirected_to new_user_registration_path
  end

  test 'index requires can_manage? access' do
    @user_without_manager = users(:bob)
    refute(@user_without_manager.can_manage?)

    sign_in @user_without_manager
    get :index
    assert_redirected_to root_path
  end

  test 'index loads' do
    sign_in @user
    get :index
    assert_response :success
  end

  test 'new project page loads' do
    sign_in @user
    get :new
    assert_response :success
  end

  test 'show loads' do
    sign_in @user
    get :show, params: { id: @project.id }
    assert_response :success
  end

  test 'edit loads' do
    sign_in @user
    get :edit, params: { id: @project.id }
    assert_response :success
  end

  test 'update alters project' do
    @project.name = 'New Name'

    sign_in @user
    patch :update, params: { id: @project.id, project: { name: 'New Name' } }
    assert_redirected_to manage_project_path(@project)
    assert_equal('New Name', @project.reload.name)
  end

  test 'create with incomplete params renders page' do
    sign_in @user
    get :create, params: { project: { name: 'Lacking Details' } }
    assert_response :success
  end

  test 'create with complete params creates project' do
    project_params = new_project_params
    sign_in @user
    assert_difference('Project.count') do
      post :create, params: { project: project_params }
    end
    assert_redirected_to manage_project_path(Project.last)
  end

  private

  def new_project_params
    project_params = @project.attributes.dup
    %w(id user_id created_at updated_at latitude longitude country).each do |key|
      project_params.delete(key)
    end
    project_params['name'] = 'New Project Name'
    project_params['append_project_images'] = [fixture_file_upload('test.jpg')]
    project_params
  end
end