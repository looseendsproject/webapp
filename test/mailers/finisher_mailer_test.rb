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
    assert_equal "/finisher/new", m.link_action
    refute m.single_use
    assert_equal "FinisherMailer.welcome", m.mailer
    assert_not_nil m.sgid
  end

  test "welcome mail should include profile link" do
    mail = FinisherMailer.with(resource: @finisher).welcome.deliver_now

    assert_match "http://example.com/finisher", mail.body.encoded
  end

  ## Profile Complete Mail

  test "should send profile complete mail with correct metadata" do
    mail = FinisherMailer.with(resource: @finisher).profile_complete.deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal "info@looseendsproject.org", mail.from.first
    assert_equal @finisher.user.email, mail.to.first
    assert_equal "Welcome, Loose Ends Finisher!", mail.subject

    m = @finisher.messages.last
    refute m.link_action
    refute m.single_use
    assert_equal "FinisherMailer.profile_complete", m.mailer
    assert_not_nil m.sgid
  end

  test "profile complete mail should include flyer link" do
    mail = FinisherMailer.with(resource: @finisher).profile_complete.deliver_now

    assert_match "https://www.looseendsproject.org/flyers", mail.body.encoded
  end
end
