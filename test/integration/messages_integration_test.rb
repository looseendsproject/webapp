# frozen_string_literal: true

require "test_helper"

class MessagesIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    setup_message!
  end

  test "show works for admin" do
    sign_in users(:admin)
    get "/message/#{Message.first.id}"
    assert_response :success
    assert_match /Subject: Test inbound from Gmail/, @response.body
  end

  test "show does not work un-authed" do
    get "/message/#{Message.first.id}"
    assert_redirected_to root_path
  end

  test "show does not work for non admins" do
    sign_in users(:basic)
    get "/message/#{Message.first.id}"
    assert_response :not_found
  end
end
