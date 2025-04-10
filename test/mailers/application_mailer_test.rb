# frozen_string_literal: true

require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase

  test "test for Project" do
    project = Project.first
    mail_message = ApplicationMailer.with(resource: project, expires_in: nil).test.deliver_now

    assert_match "http://example.com/magic_link?sgid=", mail_message.text_part.body.raw_source
    assert_match "This link does not expire", mail_message.text_part.body.raw_source
    m = project.messages.last
    assert_equal "project/Project Title One", m.description
    assert_equal "outbound", m.channel
    refute m.redirect_to
    assert m.sgid
    assert_nil m.expires_at
    refute m.single_use
    assert_equal 0, m.click_count
  end

end
