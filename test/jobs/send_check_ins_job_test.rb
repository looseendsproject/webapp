# frozen_string_literal: true

require "test_helper"

class SendCheckInsJobTest < ActiveJob::TestCase

  test "logs output" do
    SendCheckInsJob.perform_now
    assert_match "#<SendCheckInsJob:0x0", JobLog.last.output
  end

  test "queues emails" do
    SendCheckInsJob.perform_now
    assert_match "gid://looseends/Assignment/1", enqueued_jobs.last.inspect
  end

  test "doesn't send more often than every X weeks" do
    freeze_time
    time = Time.zone.now
    SendCheckInsJob.perform_now
    assert_match "gid://looseends/Assignment/1", enqueued_jobs.last.inspect
    assert_enqueued_jobs 1
    assert_equal time, Assignment.find(1).check_in_sent_at
    unfreeze_time
    perform_enqueued_jobs

    assert_enqueued_jobs 0
    travel_to 1.day.from_now
    SendCheckInsJob.perform_now
    assert_enqueued_jobs 0
    assert_equal time, Assignment.find(1).check_in_sent_at

    travel_to Assignment::CHECK_IN_INTERVAL.from_now
    SendCheckInsJob.perform_now
    assert_enqueued_jobs 1
    assert_not_equal time, Assignment.find(1).check_in_sent_at
  end
end
