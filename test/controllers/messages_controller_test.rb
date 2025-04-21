# frozen_string_literal: true

require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    sign_in users(:admin)
  end

  test "render HTML UTF-8 content" do
    get "/message/1"
    assert_response :success
  end
end
