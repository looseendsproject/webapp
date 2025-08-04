# Sends check-in emails for active projects
#
class SendCheckInsJob < ApplicationJob
  queue_as :default

  def perform
    output = output_header

    Assignment.needs_check_in.each do |assignment|
      ActiveRecord::Base.transaction do

        if assignment.missed_check_ins? # don't send another, but escalate

          assignment.project.update_attribute(:needs_attention, "finisher_unresponsive")
          assignment.update_attribute(:status, Assignment::STATUSES[:unresponsive])

          output += <<~LINE
            #{assignment.finisher.user.email}\
            \t\t\t#{assignment.finisher.user.name}\
            \t\t\t#{assignment.project.name}\
            \t\t\tUNRESPONSIVE
          LINE

        else

          FinisherMailer.with(resource: assignment,
            expires_in: 2.weeks).project_check_in.deliver_later
          assignment.update_attribute("check_in_sent_at", Time.zone.now)

          output += <<~LINE
            #{assignment.finisher.user.email}\
            \t\t\t#{assignment.finisher.user.name}\
            \t\t\t#{assignment.project.name}
          LINE

        end
      end
    end

    log_output(output)
  end
end
