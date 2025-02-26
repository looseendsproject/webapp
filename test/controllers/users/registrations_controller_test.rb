# frozen_string_literal: true

require "test_helper"

module Users
  class RegistrationsControllerTest < ActionController::TestCase
    def setup
      @request.env["devise.mapping"] = Devise.mappings[:user]
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
end
