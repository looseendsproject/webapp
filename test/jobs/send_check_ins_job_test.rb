# frozen_string_literal: true

require "test_helper"

class SendCheckInsJobTest < ActiveJob::TestCase

  def setup
    Project.find(1).update_column("status", "IN PROCESS: UNDERWAY")
  end

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

  test "escalate unresponsive" do
    @assignment = Assignment.find(1)
    user = @assignment.finisher.user
    @assignment.notes.create!(created_at: Time.now.beginning_of_day - 8.weeks, user: user)
    @assignment.notes.create!(created_at: Time.now.beginning_of_day - 6.weeks, user: user)
    @assignment.notes.create!(created_at: Time.now.beginning_of_day - 4.weeks, user: user)
    @assignment.notes.create!(created_at: Time.now.beginning_of_day - 2.weeks, user: user)
    @assignment.project.update_attribute(:status, Project::STATUSES[:in_process_underway])
    @assignment.update_attribute(:last_contacted_at,
      Time.zone.now.beginning_of_day - Assignment::UNRESPONSIVE_INTERVAL)

    assert @assignment.missed_check_ins?

    SendCheckInsJob.perform_now
    assert_enqueued_jobs 0
    assert_equal "finisher_unresponsive", @assignment.reload.project.needs_attention
    assert_equal "unresponsive", @assignment.status
    assert_match "UNRESPONSIVE", JobLog.last.output
  end
end
