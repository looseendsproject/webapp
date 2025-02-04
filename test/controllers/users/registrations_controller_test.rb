require 'test_helper'

class Users::RegistrationsControllerTest < ActionController::TestCase
  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @params = { user: {
      first_name: 'Testy',
      last_name: 'Test',
      email: 'testy@test.us',
      heard_about_us: 'Super Bowl Ad',
      password: '0sgyrg0FoaLoKgtgFxfb',
      password_confirmation: '0sgyrg0FoaLoKgtgFxfb'
    } }
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "nil heard_about_us does not validate" do
    @params[:user][:heard_about_us] = ''
    post :create, params: @params
    assert_response :success
    assert @response.parsed_body.include? "1 error prohibited this user from being saved"
  end

  test "new user validates" do
    post :create, params: @params
    assert_redirected_to :root
    assert User.last.first_name == 'Testy'
  end
end
