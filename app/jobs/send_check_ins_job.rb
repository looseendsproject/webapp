# Sends check-in emails for active projects
#
class SendCheckInsJob < ApplicationJob
  queue_as :default

  def perform
    output = output_header

    Assignment.needs_check_in.each do |assignment|
      FinisherMailer.with(resource: assignment,
        expires_in: 2.weeks).project_check_in.deliver_later
      output += <<~LINE
        #{assignment.finisher.user.email}\
        \t#{assignment.finisher.user.name}\
        \t#{assignment.project.name}
      LINE
    end

    log_output(output)
  end
end
