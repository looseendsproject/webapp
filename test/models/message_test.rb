# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  channel          :string
#  click_count      :integer          default(0), not null
#  description      :string
#  email_headers    :jsonb            not null
#  expires_at       :datetime
#  last_edited_by   :integer
#  messageable_type :string
#  redirect_to      :string
#  sgid             :string
#  single_use       :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  messageable_id   :bigint
#
# Indexes
#
#  index_messages_on_channel                              (channel)
#  index_messages_on_messageable                          (messageable_type,messageable_id)
#  index_messages_on_messageable_type_and_messageable_id  (messageable_type,messageable_id)
#  index_messages_on_sgid                                 (sgid)
#
require "test_helper"

class MessageTest < ActiveSupport::TestCase

  test "validations" do
    m = Project.first.messages.new(channel: 'wrong')
    refute m.valid?
    assert_match /Channel wrong is not a valid message channel/, m.errors.full_messages.to_s
  end

  test "persists to Project" do
    m = Project.first.messages.new
    m.content = "Primo content"
    m.save!

    assert_equal "Primo content", Project.first.messages.last.content.body.to_plain_text
  end

  test "persists to Finisher" do
    m = Finisher.first.messages.new
    m.content = "Finisher content"
    m.save!

    assert_equal "Finisher content", Finisher.first.messages.last.content.body.to_plain_text
  end

  test "persists to User" do
    m = User.first.messages.new
    m.content = "Something about the User..."
    m.save!

    assert_equal "Something about the User...", User.first.messages.last.content.body.to_plain_text
  end

  test "Updates assignment last_contacted_at for Project" do
    project = Project.first
    project.status = "IN PROCESS: UNDERWAY"
    assignment = project.active_assignment
    assignment.update_attribute("last_contacted_at", nil) # set up fixture

    assert(assignment)
    assert_nil(assignment.last_contacted_at)

    m = project.messages.new
    m.channel = "inbound"
    m.content = "Primo content"
    m.save!

    # HACK Temporarily disabled updating
    #
    assert_nil(assignment.reload.last_contacted_at)
  end

  test "does not update last_contacted_at unless active assignment and project in process" do
    project = Project.first
    project.status = "anything except in process"
    assignment = project.active_assignment
    assignment.update_attribute("last_contacted_at", nil) # set up fixture

    assert(assignment)
    assert_nil(assignment.last_contacted_at)

    m = project.messages.new
    m.channel = "inbound"
    m.content = "Primo content"
    m.save!

    assert_nil(assignment.reload.last_contacted_at)
  end

  test "#user returns a User no matter the messageable_type" do
    assert_equal User, Message.find(1).user.class # from Project (points to Project Owner)
    assert_equal User, Message.find(2).user.class # from Finisher
    assert_equal User, Message.find(3).user.class # from User directly
  end

  test "attaches ActiveStorage email_source via File.open and parses correctly" do
    message = Project.first.messages.new(channel: "inbound")
    message.email_source.attach(io: File.open(Rails.root.join("test/fixtures/files/sample_3.eml")),
      filename: "source.eml", content_type: "text/plain")
    message.save!

    mail = message.mail
    assert_equal "joan@looseendsproject.org", mail.from.first
    assert_equal [
      "project-testy@parse.looseendsproject.org", "testytest@gmail.com",
      "more_testy@yahoo.com"], mail.to
    assert_equal DateTime.parse("Mon, 14 Apr 2025 09:50:20 -0600"), mail.date
    assert_equal "multipart/alternative; boundary=000000000000e8379e0632bf02c7",
      mail.content_type
    assert_equal "text/plain; charset=UTF-8", mail.text_part.content_type
    assert_equal "text/html; charset=UTF-8", mail.html_part.content_type
    assert_equal "quoted-printable", mail.html_part.content_transfer_encoding
  end

  test "can attach source as StringIO" do
    text = File.read(Rails.root.join("test/fixtures/files/sample_3.eml"))
    message = Project.first.messages.new(channel: "inbound")
    message.email_source.attach(io: StringIO.new(text),
      filename: "source.eml", content_type: "text/plain")
    message.save!

    mail = message.mail
    assert_equal "joan@looseendsproject.org", mail.from.first
    assert_equal [
      "project-testy@parse.looseendsproject.org", "testytest@gmail.com",
      "more_testy@yahoo.com"], mail.to
    assert_equal DateTime.parse("Mon, 14 Apr 2025 09:50:20 -0600"), mail.date
    assert_equal "multipart/alternative; boundary=000000000000e8379e0632bf02c7",
      mail.content_type
    assert_equal "text/plain; charset=UTF-8", mail.text_part.content_type
    assert_equal "text/html; charset=UTF-8", mail.html_part.content_type
    assert_equal "quoted-printable", mail.html_part.content_transfer_encoding
  end

  test "stash headers" do
    mail_message = Mail.from_source File.read(Rails.root.join("test/fixtures/files/sample_3.eml"))
    headers = Message.first.stash_headers(mail_message)
    assert_equal DateTime.parse("Mon, 14 Apr 2025 09:50:20 -0600"), headers[:date]
    assert_equal ["joan@looseendsproject.org"], headers[:from]
    assert_equal ["project-testy@parse.looseendsproject.org",
      "testytest@gmail.com", "more_testy@yahoo.com"], headers[:to]
    assert_nil headers[:cc]
    assert_equal "Introducing a Project and a Finisher / Loose Ends: maroon knit sweater vest",
      headers[:subject]
  end

  test "valid_headers?" do
    message = Message.first
    mail_message = Mail.from_source File.read(Rails.root.join("test/fixtures/files/sample_3.eml"))
    headers = message.stash_headers(mail_message)
    assert message.valid_headers?

    message.email_headers = {}
    refute message.valid_headers?

    message.email_headers = {
      "cc"=>nil,
      "to"=>["project-15eo7ge2@parse-staging.looseendsproject.org"],
      "date"=>"2025-04-29T16:40:36.000-04:00",
      "from"=>["testy_test@gmail.com"],
      "size"=>27755,
      "subject"=>"quoted-printable?",
      "attachments"=>1
    }
    assert message.valid_headers?
  end

  test "since method" do
    start = Time.now - 3.days
    target = Message.where(created_at: (start..Time.now)).count
    assert_equal target, Message.since(start).count
  end

  test "set_sgid" do
    m = Message.find(1)
    refute m.sgid

    # Default (bare) call
    m.set_sgid!
    assert m.sgid
    refute m.redirect_to
    assert m.expires_at > Time.zone.now
    refute m.single_use

    # Can't overwrite
    assert_raises(Message::SGIDExistsError) { m.set_sgid!(single_use: true) }
  end

  test "expired?" do
    m = Message.find(4)
    travel_to m.expires_at - 1.day
    refute m.expired?
    travel_to m.expires_at + 1.day
    assert m.expired?
  end

  test "valid_sgid? under all scenarios" do
    # valid
    m = Message.find(4)
    travel_to m.expires_at - 1.day
    assert m.valid_sgid?

    # expired
    travel_to m.expires_at + 1.day
    refute m.valid_sgid?
    travel_back

    # used up
    travel_to m.expires_at - 1.day
    m.single_use = true
    m.click_count = 1
    refute m.valid_sgid?

    # not applicable
    assert Message.find(1).valid_sgid?
  end
end
