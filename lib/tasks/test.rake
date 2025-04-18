# frozen_string_literal: true

namespace :test do

  ### NOT FOR PRODUCTION!

  # Use mailcatcher in development https://mailcatcher.me/
  #
  desc "Send one of every custom Mailer message to local or staging recipient"
  task mailer_messages: [:environment] do |_t|
    # Unless we replace Devise::Mailer, not easy to trigger those here
    ApplicationMailer.with(resource: Finisher.first).test.deliver_now
    FinisherMailer.with(resource: Finisher.first).welcome.deliver_now
    FinisherMailer.with(resource: Finisher.first).profile_complete.deliver_now
  end

  desc "Send an expired sgid for manual testing"
  task expired_sgid: [:environment] do |_t|
    FinisherMailer.with(resource: Finisher.first, expires_in: 1.second) \
      .welcome.deliver_now
  end

  desc "Trigger a check-in email"
  task project_check_in: [:environment] do |_t|
    FinisherMailer.with(resource: Assignment.active.first, expires_in: 2.weeks) \
      .project_check_in.deliver_now
  end

  desc "Seed some job_logs"
  task seed_job_logs: [:environment] do |_t|
    50.times do
      JobLog.create!(output: Faker::Lorem.paragraph(sentence_count: 40))
    end
  end

  desc "Dump status combinations"
  task dump_statuses: [:environment] do |_t|
    Project::STATUSES.map do |status|
      if status == "ready to match"
        Project::READY_TO_MATCH_STATUSES.map do |rtm|
          puts "#{status.upcase}:#{rtm.upcase}"
        end
      elsif status == "in process"
        Project::IN_PROCESS_STATUSES.map do |ips|
          puts "#{status.upcase}:#{ips.upcase}"
        end
      else
        puts status.upcase
      end
    end
    Assignment::STATUS.map { |s| puts s.upcase }
  end

end
