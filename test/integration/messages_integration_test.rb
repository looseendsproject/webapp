# frozen_string_literal: true

require "test_helper"

class MessagesIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    @message = Message.find(1)
  end

  test "show works for admin" do
    sign_in users(:admin)
    get "/message/#{@message.id}"
    assert_response :success
    assert_match /test with png attachment/, @response.body
  end

  test "show does not work un-authed" do
    get "/message/#{@message.id}"
    assert_redirected_to root_path
  end

  test "show does not work for non admins" do
    sign_in users(:basic)
    get "/message/#{@message.id}"
    assert_response :not_found
  end
end
