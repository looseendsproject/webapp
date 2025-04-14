# frozen_string_literal: true

require "test_helper"

class JobLogTest < ActiveSupport::TestCase

  test "since scope" do
    assert_equal 1, JobLog.since(3.days.ago).count
  end
end
