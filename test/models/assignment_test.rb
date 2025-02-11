require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @assignment = assignments(:knit_active)
  end

  test "all fixtures are valid by default" do
    Assignment.all.each do |assignment|
      assert(assignment.valid?, "Assignment fixture should be valid: #{assignment.errors.full_messages.to_sentence}")
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
      assert @assignment.valid?, "Status #{status} should be valid"
    end
  end

  test "allows nil status" do
    @assignment.status = nil
    assert @assignment.valid?
  end

  test "active scope" do
    assert_includes Assignment.active, assignments(:knit_active)
    assert_not_includes Assignment.active, assignments(:knit_inactive)
  end
end
