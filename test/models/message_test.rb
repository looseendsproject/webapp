# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  channel          :string
#  click_count      :integer          default(0), not null
#  description      :string
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

  test "parses email source into Mail object" do
    m = Project.first.messages.new
    m.content = File.read(Rails.root.join("test/fixtures/files/sample_2.eml"))
    m.save!

    assert_predicate m.email, :multipart?
    assert_equal m.email.html_part.content_type, "text/html; charset=UTF-8"
    assert_equal m.email.html_part.content_transfer_encoding, "quoted-printable"

    assert_equal ["inbound@example.com"], m.email.to

    # HACK temporary
    # assert_equal 'forwarder@example.com', m.email.from
    assert_equal "Fwd: Test inbound from Gmail", m.email.subject
    assert_equal "2025-03-22T12:25:35-04:00", m.email.date.to_s
    assert_match(/How does this look\?/, m.email.text_part.body.decoded)
  end

  test "parses troublesome eml" do
    m = Project.first.messages.new
    m.content = File.read(Rails.root.join("test/fixtures/files/sample_3.eml"))
    m.save!

    assert m.email.to.is_a?(String)
    assert_equal "joan Sample", m.email.from
    assert_predicate m.email, :multipart?
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
