# frozen_string_literal: true

require "test_helper"

class FinisherAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @knitter = finishers :knitter
  end

  test "project page logged out" do
    get "/finisher"
    assert_redirected_to "/"
  end

  test "project page logged in" do
    sign_in @knitter.user
    get "/finisher"
    assert_response :success
  end
end
