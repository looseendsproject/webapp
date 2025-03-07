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

  test 'new registration sends confirmation instructions email' do
    post :create, params: { user: {
      first_name: 'First',
      last_name: 'Last',
      email: 'me@example.com',
      heard_about_us: 'Blimp Ad',
      password: 'not_a_good_password',
      password_confirmation: 'not_a_good_password'
    } }
    assert_response :redirect
    assert_equal User.last.email, 'me@example.com'
    assert_equal "Confirmation instructions", ActionMailer::Base.deliveries.last.subject
    assert_equal  ['me@example.com'], ActionMailer::Base.deliveries.last.to
  end
end
