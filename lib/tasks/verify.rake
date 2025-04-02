# frozen_string_literal: true

namespace :verify do
  desc "Make sure solid_queue is working"
  task solid_queue: [:environment] do |_t|
    10.times do
      TestJob.perform_later
    end
  end

  # Use mailcatcher in development https://mailcatcher.me/
  #
  desc "Send one of every custom Mailer message to local or staging recipient"
  task mailer_messages: [:environment] do |_t|
    raise "Does not work in production or if RAILS_ENV_DISPLAY.blank?!" \
      if ENV["RAILS_ENV_DISPLAY"].blank?  || ENV["RAILS_ENV_DISPLAY"] == 'production'

    # Unless we replace Devise::Mailer, not easy to trigger those here

    ApplicationMailer.with(resource: Finisher.first).test.deliver_now
    FinisherMailer.with(resource: Finisher.first).welcome.deliver_now
    FinisherMailer.with(resource: Finisher.first).profile_complete.deliver_now
  end
end
