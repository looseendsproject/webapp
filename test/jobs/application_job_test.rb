# frozen_string_literal: true

require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  test "log_output" do
    klass = ApplicationJob.new
    klass.log_output <<~OUTPUT
      ApplicationJob#log_output 2025-04-10 7:05AM EDT
      =====================================================

      Log line 1
      Log line 2
    OUTPUT
    assert_match "ApplicationJob#log_output", JobLog.last.output
  end
end
