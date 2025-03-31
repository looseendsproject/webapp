# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  channel          :string
#  description      :string
#  last_edited_by   :integer
#  messageable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  messageable_id   :bigint
#
# Indexes
#
#  index_messages_on_channel                              (channel)
#  index_messages_on_messageable                          (messageable_type,messageable_id)
#  index_messages_on_messageable_type_and_messageable_id  (messageable_type,messageable_id)
#
require "test_helper"

class MessageTest < ActiveSupport::TestCase

  test "validations" do
    m = Project.first.messages.new(channel: 'wrong')
    # debugger
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
    assignment = project.active_assignment

    assert(assignment)
    assert_nil(assignment.last_contacted_at)

    m = project.messages.new
    m.channel = "inbound"
    m.content = "Primo content"
    m.save!

    assert_not_nil(assignment.reload.last_contacted_at)
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
    assert_equal ["inbound@example.com"], m.email.to
    # TODO: assert_equal 'forwarder@example.com', m.email.from
    assert_equal "Fwd: Test inbound from Gmail", m.email.subject
    assert_equal "2025-03-22T12:25:35-04:00", m.email.date.to_s
    assert_match(/How does this look\?/, m.email.text_part.body.decoded)
  end

  test "since method" do
    start = Time.now - 3.days
    target = Message.where(created_at: (start..Time.now)).count
    assert_equal target, Message.since(start).count
  end
end
