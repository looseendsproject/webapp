# frozen_string_literal: true

require "test_helper"

class FinisherMailerTest < ActionMailer::TestCase
  setup do
    @finisher = finishers(:knitter)
  end

  ## Welcome Mail

  test "should send welcome mail with correct metadata" do
    mail = FinisherMailer.welcome(@finisher).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal "info@looseendsproject.org", mail.from.first
    assert_equal @finisher.user.email, mail.to.first
    assert_equal "Loose Ends Project Account Created - Next Steps...", mail.subject
  end

  test "welcome mail should include profile link" do
    mail = FinisherMailer.welcome(@finisher).deliver_now

    assert_match "http://example.com/finisher", mail.body.encoded
  end

  ## Profile Complete Mail

  test "should send profile complete mail with correct metadata" do
    mail = FinisherMailer.profile_complete(@finisher).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal "info@looseendsproject.org", mail.from.first
    assert_equal @finisher.user.email, mail.to.first
    assert_equal "Welcome, Loose Ends Finisher!", mail.subject
  end

  test "profile complete mail should include flyer link" do
    mail = FinisherMailer.profile_complete(@finisher).deliver_now

    assert_match "https://www.looseendsproject.org/flyers", mail.body.encoded
  end
end
