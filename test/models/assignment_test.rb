# == Schema Information
#
# Table name: assignments
#
#  id                :bigint           not null, primary key
#  ended_at          :datetime
#  last_contacted_at :datetime
#  started_at        :datetime
#  status            :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  finisher_id       :bigint
#  project_id        :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_assignments_on_finisher_id  (finisher_id)
#  index_assignments_on_project_id   (project_id)
#  index_assignments_on_user_id      (user_id)
#
require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @assignment = assignments(:knit_active)
  end

  # for :messageable
  test "#user returns finisher.user" do
    assert_equal @assignment.finisher.user, @assignment.user
  end

  # TODO this may be a vestige and should be dropped. Project also
  # has manager_id and seems to be in use.
  test "#manager returns User.find(user_id)" do
    assert_equal User.find(@assignment.user_id), @assignment.manager
  end

  test "all fixtures are valid by default" do
    Assignment.all.each do |assignment|
      assert_predicate(assignment, :valid?,
                       "Assignment fixture should be valid: #{assignment.errors.full_messages.to_sentence}")
    end
  end

  test "does not allow unknown status" do
    @assignment.status = "unknown"

    assert_not @assignment.valid?
    assert_includes @assignment.errors.full_messages, "Status is not included in the list"
  end

  test "allows known status" do
    Assignment::STATUS.each do |status|
      @assignment.status = status

      assert_predicate @assignment, :valid?, "Status #{status} should be valid"
    end
  end

  test "allows nil status" do
    @assignment.status = nil

    assert_predicate @assignment, :valid?
  end

  test "empty status coerced into nil" do
    @assignment.status = ""

    assert_predicate @assignment, :valid?
    @assignment.save!

    assert_nil @assignment.reload.status
  end

  test "active scope" do
    assert_includes Assignment.active, assignments(:knit_active)
    assert_not_includes Assignment.active, assignments(:knit_inactive)
  end
end
