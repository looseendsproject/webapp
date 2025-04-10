# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def log_output(output)
    JobLog.create!(output: output)
  end

  private

    def output_header
      <<~HEAD
        #{self.inspect}
        ========================================================================


      HEAD
    end
end
