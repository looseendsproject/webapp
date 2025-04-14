# == Schema Information
#
# Table name: notes
#
#  id           :bigint           not null, primary key
#  notable_type :string
#  sentiment    :string
#  text         :text
#  visibility   :string           default("manager"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  notable_id   :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_notes_on_notable  (notable_type,notable_id)
#  index_notes_on_user_id  (user_id)
#
require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "persists to Project" do
    n = Project.first.notes.new
    n.text = "Got a call from finisher.  Going well"
    n.user_id = 3
    n.sentiment = nil
    n.save!

    assert_equal "Got a call from finisher.  Going well", Project.first.notes.last.text
    refute Project.first.notes.last.sentiment
    assert_equal 'manager', Project.first.notes.last.visibility
    assert_equal "mick@gmail.com", Project.first.notes.last.user.email
  end

  test "persists to Assignment" do
    n = Assignment.first.notes.new
    n.text = "Going great!  Almost done"
    n.sentiment = "Going well"
    n.user_id = 2
    n.save!

    assert_equal "Going great!  Almost done", Assignment.first.notes.last.text
    assert_equal "Going well", Assignment.first.notes.last.sentiment
    assert_equal "finisher", Assignment.first.notes.last.visibility
    assert_equal "fred@gmail.com", Assignment.first.notes.last.user.email
  end

  test "#negative?" do
    n = Assignment.first.notes.new(sentiment: "going_well")
    refute n.negative?

    n.sentiment = "no_progress"
    refute n.negative?

    n.sentiment = "not_great"
    assert n.negative?
  end
end
