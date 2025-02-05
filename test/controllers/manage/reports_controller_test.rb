# frozen_string_literal: true

require "test_helper"

module Manage
  class ReportsControllerTest < ActionController::TestCase
    test "heard_about_us" do
      sign_in users(:admin)
      get :heard_about_us
      assert_response :success
    end
  end
end
