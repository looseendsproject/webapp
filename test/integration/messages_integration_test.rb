# frozen_string_literal: true

require "test_helper"

class MessagesIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    @message = Message.find(1)
    @message.email_source.attach(io: File.open(Rails.root.join("test/fixtures/files/sample_png.eml")),
      filename: "source.eml", content_type: "text/plain")
    @message.save!
  end

  test "show works for admin" do
    sign_in users(:admin)
    get "/message/#{@message.id}"
    assert_response :success
    assert_match /test with png attachment/, @response.body
  end

  test "show does not work un-authed" do
    get "/message/#{@message.id}"
    assert_redirected_to new_user_session_path
  end

  test "show does not work for non admins" do
    sign_in users(:basic)
    get "/message/#{@message.id}"
    assert_response :not_found
  end
end
