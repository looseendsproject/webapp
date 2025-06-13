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
    assert_not Project.first.notes.last.sentiment
    assert_equal "manager", Project.first.notes.last.visibility
    assert_equal "mick@gmail.com", Project.first.notes.last.user.email
  end

  test "persists to Assignment" do
    n = Assignment.first.notes.new
    n.text = "Going great!  Almost done"
    n.sentiment = "going_well"
    n.user_id = 2
    n.save!

    assert_equal "Going great!  Almost done", Assignment.first.notes.last.text
    assert_equal "going_well", Assignment.first.notes.last.sentiment
    assert_equal "finisher", Assignment.first.notes.last.visibility
    assert_equal "fred@gmail.com", Assignment.first.notes.last.user.email
  end

  test "validates sentiment is a valid value" do
    note = Assignment.first.notes.new sentiment: "invalid_sentiment", text: "This is a test", user: users(:finisher)

    assert_not_predicate note, :valid?
    assert_includes note.errors[:sentiment], "is not included in the list"
  end

  test "for_assignments scope" do
    assert_equal 2, Note.count
    assignment_notes = Note.for_assignment

    assert_equal 1, assignment_notes.count
    assert_equal "All good!", assignment_notes.first.text
  end

  test "requires sentiment for Assignment note" do
    note = Assignment.first.notes.new sentiment: "going_well", text: "", user: users(:finisher)

    assert_predicate note, :valid?

    note = Assignment.first.notes.new text: "no sentiment", user: users(:finisher)

    assert_not note.valid?

    note = Assignment.first.notes.new sentiment: "", text: "no sentiment", user: users(:finisher)

    assert_not note.valid?
  end

  test "requires text for negative note" do
    note = Assignment.first.notes.new sentiment: "need_help", text: "", user: users(:finisher)

    assert_not note.valid?

    note = Assignment.first.notes.new sentiment: "need_help", text: "this sux", user: users(:finisher)

    assert_predicate note, :valid?
  end

  test "#negative?" do
    n = Assignment.first.notes.new(sentiment: "going_well")

    assert_not_predicate n, :negative?

    n.sentiment = "no_progress"

    assert_not_predicate n, :negative?

    n.sentiment = "need_help"

    assert_predicate n, :negative?
  end
end
