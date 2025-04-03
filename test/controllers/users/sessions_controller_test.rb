# frozen_string_literal: true

# see https://www.magicalruby.com/implementing-magic-links-in-rails/

require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @message = Message.find(4)
  end

  test 'good magic link does the necessary' do
    travel_to @message.expires_at - 1.day
    get "/magic_link", params: { sgid: @message.sgid }
    assert_redirected_to @message.link_action
  end

  test 'fake SGID throws 404' do
    get "/magic_link", params: { sgid:"IAMABADGUYSPOOFINGSGIDS" }
    assert_response :not_found
  end

  test 'expired link renders resend' do
    travel_to @message.expires_at + 1.day
    get "/magic_link", params: { sgid: @message.sgid }
    assert_response :success
    assert_match "Your original link expired.  A new link was automatically sent to you.",
      response.body
  end

  test 'missing params redirects with flash error' do
    get "/magic_link", params: {}
    assert_redirected_to '/users/sign_in'
    assert_equal "Bad link. Please sign in to proceed.", flash[:error]
  end
end
