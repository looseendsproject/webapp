require 'test_helper'

class Users::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test '#new loads page with form' do
    get '/users/confirmation/new'
    assert_match /Resend confirmation instructions/, @response.body
  end

  test '#create sends email with correct link' do
    post '/users/confirmation', params: { user: { email: users(:admin).email }}
    assert_redirected_to new_user_session_url
    message = ActionMailer::Base.deliveries.last
    assert_match "http://example.com/users/confirmation?confirmation_token=",
      ActionMailer::Base.deliveries.last.body.encoded
  end
end
