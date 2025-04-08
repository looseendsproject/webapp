# frozen_string_literal: true

require "test_helper"

class Users::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test 'create sends reset instructions' do
    post '/users/password', params: { user: { email: User.last.email } }
    assert_redirected_to "/users/sign_in"
    assert_equal "Reset password instructions", ActionMailer::Base.deliveries.last.subject
    assert_equal [User.last.email], ActionMailer::Base.deliveries.last.to
  end
end
