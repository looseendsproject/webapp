require "test_helper"

class ForwardsMailboxTest < ActionMailbox::TestCase

  def setup
    @inbound = create_inbound_email_from_fixture("sample.eml", status: :pending)
  end

  test 'message is created from fixture' do
    assert_equal ['no-reply@example.com'], @inbound.mail.from
    assert_equal ['inbound@parse-staging.example.com'], @inbound.mail.to
    assert_equal "Fwd: Getting started with ActiveMailbox", @inbound.mail.subject
    assert_match /---------- Forwarded message ---------\n/, @inbound.mail.decode_body
    assert_equal 'pending', @inbound.status
  end

  test 'routing' do
    assert_equal ForwardsMailbox, ApplicationMailbox.mailbox_for(@inbound)
    debugger
  end
end
