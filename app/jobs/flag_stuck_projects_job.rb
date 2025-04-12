# Tags Projects that need Manager attention
#
class FlagStuckProjects < ApplicationJob
  queue_as :default

  def perform
    output = output_header

    output += flag negative_sentiment
    output += flag stalled_accepted
    output += flag stalled_invited
    output += flag stalled_potential
    output += flag long_running

    log_output output
  end

  protected

    # project.needs_attention value must be in
    #  Project::NEEDS_ATTENTION_REASONS

    # Negative response from check-in
    #
    def negative_sentiment
      # these should be set by AssessmentsController
      # when a Note is added
    end

    # Check-in emails sent, but no response
    #
    def stalled_accepted
    end

    # Invited but not accepted after X days
    #
    def stalled_invited
    end

    # Potential with no movement
    #
    def stalled_potential
    end

    # Too long since project start,
    # regardless of check-in sentiment
    #
    def long_running
    end

    # Set project.needs_attention
    #
    def flag(assignments)
      # output_header
      # assignments.update_all(needs_attention: <value>)
    end
end
