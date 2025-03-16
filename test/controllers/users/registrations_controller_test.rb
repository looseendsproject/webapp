require 'test_helper'

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def setup
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
    get '/users/sign_up'
    assert_response :success
  end

  test "nil heard_about_us does not validate" do
    @params[:user][:heard_about_us] = ''
    post '/users', params: @params
    assert_response :success
    assert_match(/Heard about us can&#39;t be blank/, @response.body)
  end

  test "new user validates" do
    post '/users', params: @params
    assert_redirected_to :root
    assert User.last.first_name == 'Testy'
  end

  test 'new registration sends confirmation instructions email' do
    post '/users', params: { user: {
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
