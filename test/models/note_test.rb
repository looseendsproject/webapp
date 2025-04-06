require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "persists to Project" do
    n = Project.first.notes.new
    n.text = "Got a call from finisher.  Going well"
    n.rating = 1
    n.save!

    assert_equal "Got a call from finisher.  Going well", Project.first.notes.last.text
    assert_equal 1, Project.first.notes.last.rating
    assert_equal 'manager', Project.first.notes.last.visibility
  end

  test "persists to Assignment" do
    n = Assignment.first.notes.new
    n.text = "Going great!  Almost done"
    n.rating = 1
    n.save!

    assert_equal "Going great!  Almost done", Assignment.first.notes.last.text
    assert_equal 1, Assignment.first.notes.last.rating
    assert_equal "finisher", Assignment.first.notes.last.visibility
  end
end
