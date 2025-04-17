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
      sentiment: "going_well",
      text: "here's a very nice note"
    }}
    assert_redirected_to "/thank_you"
  end

  test "negative sentiment sends manager email" do
    post "/assignment/#{@assignment.id}/check_in", params: { note: {
      sentiment: "not_great",
      text: "this thing is a mess"
    }}
    assert_redirected_to "/thank_you"
    deliver_enqueued_emails
    assert_equal @assignment.project.manager.email,
      ActionMailer::Base.deliveries.last.to.first
    assert_equal "negative_sentiment", @assignment.project.needs_attention
  end

  test "rando cannot create note" do
    sign_out(@assignment.finisher.user)
    get "/assignment/#{@assignment.id}/check_in"
    assert_redirected_to "/users/sign_in"
  end
end
