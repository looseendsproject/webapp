# frozen_string_literal: true

require "test_helper"

class FinisherMailerTest < ActionMailer::TestCase
  setup do
    @finisher = finishers(:knitter)
  end

  ## Welcome Mail

  test "should send welcome mail with correct metadata" do
    mail = FinisherMailer.with(resource: @finisher).welcome.deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal "info@looseendsproject.org", mail.from.first
    assert_equal @finisher.user.email, mail.to.first
    assert_equal "Loose Ends Project Account Created - Next Steps...", mail.subject

    m = @finisher.messages.last

    assert_equal "/finisher/new", m.redirect_to
    refute m.single_use
    assert_not_nil m.sgid
  end

  test "welcome mail should include profile link" do
    mail = FinisherMailer.with(resource: @finisher).welcome.deliver_now

    assert_match "http://example.com/magic_link?sgid=", mail.body.encoded
  end

  ## Profile Complete Mail

  test "should send profile complete mail with correct metadata" do
    mail = FinisherMailer.with(resource: @finisher).profile_complete.deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal "info@looseendsproject.org", mail.from.first
    assert_equal @finisher.user.email, mail.to.first
    assert_equal "Welcome, Loose Ends Finisher!", mail.subject

    m = @finisher.messages.last

    refute m.redirect_to
    refute m.single_use
    assert_not_nil m.sgid
  end

  test "profile complete mail should include flyer link" do
    mail = FinisherMailer.with(resource: @finisher).profile_complete.deliver_now

    assert_match "https://www.looseendsproject.org/flyers", mail.body.encoded
  end

  ## Project check-in

  test "should send check-in email with magic link" do
    FinisherMailer.with(resource: Assignment.active.first, expires_in: 2.weeks) \
                  .project_check_in.deliver_now

    assert_match "How is it going?", ActionMailer::Base.deliveries.last.body.encoded
  end

  test "check-in email should have manager's reply-to" do
    assignment = assignments(:knit_active)
    manager = assignment.project.manager

    mail = FinisherMailer.with(resource: assignment, expires_in: 2.weeks).project_check_in.deliver_now

    # Note: ActionMailer test parses "Manager Name <manager@email>" and only returns the email part.
    assert_equal manager.email, mail.reply_to.first
  end
end
