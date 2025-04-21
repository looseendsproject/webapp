# frozen_string_literal: true

require "test_helper"

module Manage
  class InboundEmailsControllerTest < ActionDispatch::IntegrationTest
    def setup
      sign_in(users(:admin))
    end

    test "index" do
      get "/manage/inbound_emails"
      assert_response :success
    end
  end
end