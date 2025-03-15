require 'test_helper'

class Users::ConfirmationsControllerTest < ActionController::TestCase
  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test '#new loads page with form' do
    get :new
    assert_match /Resend confirmation instructions/, @response.body
  end

  # test '#create sends email with correct link' do
  #   post :create, params: { user_email: users(:admin) }
  #   assert_response :success
  #   assert_match 'flurp', ActionMailer::Base.deliveries.last.body
  # end
end
