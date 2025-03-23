require "test_helper"

class ForwardsMailboxTest < ActionMailbox::TestCase

  PROJECT_ADDRESS = 'Project-7A37voRf@localhost'
  FINISHER_ADDRESS = 'Finisher-AskQeXbS@localhost'

  def setup
    @inbound = create_inbound_email_from_fixture("sample.eml", status: :pending)
  end

  test 'message is created from fixture' do
    assert_equal ['forwarder@example.com'], @inbound.mail.from
    assert_equal [PROJECT_ADDRESS], @inbound.mail.to
    assert_equal "Fwd: Getting started with ActiveMailbox", @inbound.mail.subject
    assert_match /---------- Forwarded message ---------\n/, @inbound.mail.decode_body
    assert_equal 'pending', @inbound.status
  end

  test 'project found' do
    assert_equal ForwardsMailbox, ApplicationMailbox.mailbox_for(@inbound)

    # Test was throwing a pg transaction error, but this works...
    ActiveRecord::Base.transaction do
      @inbound.route
      assert_match /Subject: Getting started with ActiveMailbox/,
        Project.find(1).messages.last.content.body.to_s
      refute Project.find(2).messages.any?
    end
  end

  test 'finisher found' do
    @inbound.mail.to = FINISHER_ADDRESS
    assert_equal ForwardsMailbox, ApplicationMailbox.mailbox_for(@inbound)

    ActiveRecord::Base.transaction do
      @inbound.route
      assert_match /Subject: Getting started with ActiveMailbox/,
        Finisher.find(1).messages.last.content.body.to_s
      refute Finisher.find(2).messages.any?
    end
  end

  test 'project not found' do
    ActiveRecord::Base.transaction do
      @inbound.mail.to = "not_a_person@nowhere.com"
      assert_raises(ActiveRecord::RecordNotFound) { @inbound.route }
    end
  end
end
