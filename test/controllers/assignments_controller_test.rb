# frozen_string_literal: true

require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @assignment = assignments(:knit_active)
    sign_in(@assignment.finisher.user)
  end

  test "form loads" do
    get "/assignment/#{@assignment.id}/check_in"
    assert_response :success
  end

  test "user can create note" do
    post "/assignment/#{@assignment.id}/check_in", params: { note: {
      sentiment: "all good",
      text: "here's a very nice note"
    }}
    assert_redirected_to "/thank_you"
  end

  test "rando cannot create note" do
    sign_out(@assignment.finisher.user)
    get "/assignment/#{@assignment.id}/check_in"
    assert_redirected_to "/"
  end
end
