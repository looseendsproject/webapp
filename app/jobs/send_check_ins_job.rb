# Sends check-in emails for active projects
#
class SendCheckInsJob < ApplicationJob
  queue_as :default

  def perform
    output = output_header

    Assignment.needs_check_in.each do |assignment|
      ActiveRecord::Base.transaction do

        FinisherMailer.with(resource: assignment,
          expires_in: Assignment::CHECK_IN_INTERVAL).project_check_in.deliver_later
        assignment.update_attribute("check_in_sent_at", Time.zone.now)

        output += <<~LINE
          #{assignment.finisher.user.email}\
          \t#{assignment.finisher.user.name}\
          \t#{assignment.project.name}
        LINE
      end
    end

    log_output(output)
  end
end
