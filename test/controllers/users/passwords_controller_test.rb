# frozen_string_literal: true

require "test_helper"

module Users
  class PasswordsControllerTest < ActionController::TestCase
    def setup
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    test 'create sends reset instructions' do
      post :create, params: { user: { email: User.last.email } }
      assert_response :redirect
      assert_equal "Reset password instructions", ActionMailer::Base.deliveries.last.subject
      assert_equal [User.last.email], ActionMailer::Base.deliveries.last.to
    end

  end
end
