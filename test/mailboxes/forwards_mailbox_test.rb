require "test_helper"

class ForwardsMailboxTest < ActionMailbox::TestCase

  # Originally, addresses had upper/lower and were downcased
  # in the database.  Preserve this for backwards testing
  # of old addresses
  #
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

  test 'project found in to: array #first' do
    assert_equal ForwardsMailbox, ApplicationMailbox.mailbox_for(@inbound)

    @inbound.route
    assert_equal "Fwd: Getting started with ActiveMailbox",
      Project.find(1).messages.last.email.subject
    refute Project.find(2).messages.any?
  end

  test "project found in to: array not #first" do
    @inbound.mail.to = ["random@example.com", PROJECT_ADDRESS]
    @inbound.route
    assert_equal "Fwd: Getting started with ActiveMailbox",
      Project.find(1).messages.last.email.subject
      refute Project.find(2).messages.any?
  end

  test "project found in cc:" do
    @inbound.mail.cc = ["random@example.com", PROJECT_ADDRESS]
    @inbound.route
    assert_equal "Fwd: Getting started with ActiveMailbox",
      Project.find(1).messages.last.email.subject
    refute Project.find(2).messages.any?
  end

  test "project found in bcc:" do
    @inbound.mail.bcc = ["random@example.com", PROJECT_ADDRESS]
    @inbound.route
    assert_equal "Fwd: Getting started with ActiveMailbox",
      Project.find(1).messages.last.email.subject
    refute Project.find(2).messages.any?
  end

  test 'finisher downcased found' do
    @inbound.mail.to = FINISHER_ADDRESS.downcase
    assert_equal ForwardsMailbox, ApplicationMailbox.mailbox_for(@inbound)

    @inbound.route
    assert_equal "Fwd: Getting started with ActiveMailbox",
      Finisher.find(1).messages.last.email.subject
    refute Finisher.find(2).messages.any?
  end

  test 'finisher original case found' do
    @inbound.mail.to = FINISHER_ADDRESS
    assert_equal ForwardsMailbox, ApplicationMailbox.mailbox_for(@inbound)

    @inbound.route
    assert_equal "Fwd: Getting started with ActiveMailbox",
      Finisher.find(1).messages.last.email.subject
    refute Finisher.find(2).messages.any?
  end

  test "stash headers" do
    @inbound.route
    assert_equal "Fwd: Getting started with ActiveMailbox",
      Project.find(1).messages.last.email_headers["subject"]
  end

  test 'project not found' do
    @inbound.mail.to = "not_a_person@nowhere.com"
    assert_raises(ActiveRecord::RecordNotFound) { @inbound.route }
  end

  test "bounce too-big emails" do
    @inbound = create_inbound_email_from_fixture("too_big.eml", status: :pending)
    @inbound.route
    assert_equal "[Bounce] Email to Loose Ends Project too big", ActionMailer::Base.deliveries.last.subject
    text_body = ActionMailer::Base.deliveries.last.text_part.to_s.gsub("\r\n", " ")
    assert text_body.include?(
      "Loose Ends Project limits email attachments to under 25MB")
  end

end
