# frozen_string_literal: true

# see https://www.magicalruby.com/implementing-magic-links-in-rails/

require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @message = Message.find(4)

    # SGIDs stored in fixtures will fail CI (and tests by other devs)
    # Recreate the SGID at runtime to get the right SECRET_KEY_BASE
    #
    @message.sgid = nil
    @message.expires_at = nil
    @message.set_sgid!(redirect_to: "/finisher/new")
  end

  test 'good magic link does the necessary' do
    travel_to @message.expires_at - 1.day

    refute_predicate @message.user, :confirmed?
    get "/magic_link", params: { sgid: @message.sgid }
    assert_redirected_to @message.redirect_to
    assert_equal 1, @message.reload.click_count
    assert_predicate @message.user, :confirmed?
  end

  test 'fake SGID throws 404' do
    get "/magic_link", params: { sgid:"IAMABADGUYSPOOFINGSGIDS" }
    assert_response :not_found
  end

  test 'expired link redirects to sign in' do
    travel_to @message.expires_at + 1.day
    get "/magic_link", params: { sgid: @message.sgid }
    assert_redirected_to "/users/sign_in"
    assert_match "Expired link. Please contact support.", flash[:alert]
  end

  test 'missing params redirects with flash error' do
    get "/magic_link", params: {}
    assert_redirected_to '/users/sign_in'
    assert_equal "Bad link. Please contact support.", flash[:alert]
  end
end
