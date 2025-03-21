require "test_helper"

class ForwardsMailboxTest < ActionMailbox::TestCase

  def setup
    @inbound = create_inbound_email_from_fixture("sample.eml", status: :pending)
  end

  test 'message is created from fixture' do
    assert_equal ['forwarder@example.com'], @inbound.mail.from
    assert_equal ['inbound@parse-staging.example.com'], @inbound.mail.to
    assert_equal "Fwd: Getting started with ActiveMailbox", @inbound.mail.subject
    assert_match /---------- Forwarded message ---------\n/, @inbound.mail.decode_body
    assert_equal 'pending', @inbound.status
  end

  test 'project found' do
    assert_equal ForwardsMailbox, ApplicationMailbox.mailbox_for(@inbound)

    # Test was throwing a pg transaction error, but this works...
    ActiveRecord::Base.transaction do
      @inbound.route
      # TODO make sure Message was persisted
    end
  end

  test 'project not found' do
    ActiveRecord::Base.transaction do
      @inbound.mail.raw_source.gsub!(/fred@gmail.com/, 'nobody@gmail.com')
      assert_raises(ActiveRecord::RecordNotFound) { @inbound.route }
    end
  end
end
