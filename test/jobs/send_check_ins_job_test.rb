# frozen_string_literal: true

require "test_helper"

class SendCheckInsJobTest < ActiveJob::TestCase

  test "logs output" do
    SendCheckInsJob.perform_now
    assert_match "#<SendCheckInsJob:0x0", JobLog.last.output
  end

  test "queues emails" do
    SendCheckInsJob.perform_now
    assert_match "gid://looseends/Finisher/2", enqueued_jobs.last.inspect
  end
end
