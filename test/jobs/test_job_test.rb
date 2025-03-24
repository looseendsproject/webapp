require "test_helper"

class TestJobTest < ActiveJob::TestCase
  test "output" do
    assert_match /^TestJob: /, TestJob.perform_now
  end
end
