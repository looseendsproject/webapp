# == Schema Information
#
# Table name: notes
#
#  id           :bigint           not null, primary key
#  notable_type :string
#  rating       :integer
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
    n.rating = 1
    n.save!

    assert_equal "Got a call from finisher.  Going well", Project.first.notes.last.text
    assert_equal 1, Project.first.notes.last.rating
    assert_equal 'manager', Project.first.notes.last.visibility
    assert_equal "mick@gmail.com", Project.first.notes.last.user.email
  end

  test "persists to Assignment" do
    n = Assignment.first.notes.new
    n.text = "Going great!  Almost done"
    n.rating = 1
    n.user_id = 2
    n.save!

    assert_equal "Going great!  Almost done", Assignment.first.notes.last.text
    assert_equal 1, Assignment.first.notes.last.rating
    assert_equal "finisher", Assignment.first.notes.last.visibility
    assert_equal "fred@gmail.com", Assignment.first.notes.last.user.email
  end
end
