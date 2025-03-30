# frozen_string_literal: true

# see https://www.magicalruby.com/implementing-magic-links-in-rails/

require "test_helper"

DURATION = 48.hours

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest

  def magic_link_params
    @user = Finisher.first.user
    @path = '/finisher/new'
    { path: @path, sgid: @user.to_sgid(expires_in: DURATION, for: @path).to_s }
  end

  test 'good magic link does the necessary' do
    get "/magic_link", params: magic_link_params
    assert_redirected_to @path
  end

  # Spoofed SGID might oughta redirect to sign_in (and tell somebody...)
  test 'fake SGID throws 404' do
    params = magic_link_params
    params[:sgid] = "IAMABADGUYSPOOFINGSGIDS"
    get "/magic_link", params: params
    assert_response :not_found
  end

  test 'expired link renders resend' do
    params = magic_link_params # get the sgid before time traveling
    get "/magic_link", params: params
    assert_redirected_to params[:path]

    travel 49.hours
    get "/magic_link", params: params
    assert_response :success
    assert_match /Expired link.  Click below to re-send/, response.body
    travel_back
  end

  # Somebody's trying to use a link to go to a different path
  test 'valid link disallows out of scope requests' do
    params = magic_link_params
    params[:path] = '/different/path'
    get "/magic_link", params: params
    assert_response :not_found
  end

  test 'missing params redirects with flash error' do
    get "/magic_link", params: {}
    assert_redirected_to '/users/sign_in'
    assert_equal "Bad link. Please sign in to proceed.", flash[:error]
  end

  # test 'button resends the link with a new SGID to the right email address' do
  #   assert false
  # end
end
