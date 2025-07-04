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
    } }

    assert_redirected_to "/thank_you"
  end

  test "any response updates last_contacted_at" do
    old_date = @assignment.last_contacted_at
    post "/assignment/#{@assignment.id}/check_in", params: { note: {
      sentiment: "going_well",
      text: "here's a very nice note"
    } }

    assert_operator @assignment.reload.last_contacted_at, :>, old_date
  end

  test "negative sentiment sends manager email" do
    post "/assignment/#{@assignment.id}/check_in", params: { note: {
      sentiment: "need_help",
      text: "this thing is a mess"
    } }

    assert_redirected_to "/thank_you"
    deliver_enqueued_emails

    assert_equal @assignment.project.manager.email,
                 ActionMailer::Base.deliveries.last.to.first
    assert_equal "negative_sentiment", @assignment.project.needs_attention
  end

  test "completed sentiment sends manager email" do
    post "/assignment/#{@assignment.id}/check_in", params: { note: {
      sentiment: "completed",
      text: "all done"
    } }

    assert_redirected_to "/thank_you"
    deliver_enqueued_emails

    assert_equal @assignment.project.manager.email,
                 ActionMailer::Base.deliveries.last.to.first
    assert_equal "completed", @assignment.project.needs_attention
  end

  test "positive sentiment does not send manager email" do
    post "/assignment/#{@assignment.id}/check_in", params: { note: {
      sentiment: "going_well",
      text: "chugging along"
    } }

    assert_redirected_to "/thank_you"
    deliver_enqueued_emails

    assert_nil ActionMailer::Base.deliveries.last
  end

  test "rando cannot create note" do
    sign_out(@assignment.finisher.user)
    get "/assignment/#{@assignment.id}/check_in"

    assert_redirected_to "/users/sign_in"
  end

  test "must have sentiment, text not required unless need_help" do
    post "/assignment/#{@assignment.id}/check_in", params: { note: { sentiment: "going_well" } }

    assert_redirected_to "/thank_you"

    post "/assignment/#{@assignment.id}/check_in", params: { note: {} }

    assert_response :bad_request

    post "/assignment/#{@assignment.id}/check_in", params: { note: { text: "text" } }

    assert_response :unprocessable_content

    post "/assignment/#{@assignment.id}/check_in", params: { note: { sentiment: "need_help", text: "" } }

    assert_response :unprocessable_content
  end
end
