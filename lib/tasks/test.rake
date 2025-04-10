# frozen_string_literal: true

namespace :test do

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

  desc "Send an expired sgid for manual testing"
  task expired_sgid: [:environment] do |_t|
    raise "Does not work in production or if RAILS_ENV_DISPLAY.blank?!" \
      if ENV["RAILS_ENV_DISPLAY"].blank?  || ENV["RAILS_ENV_DISPLAY"] == 'production'

    FinisherMailer.with(resource: Finisher.first, expires_in: 1.second) \
      .welcome.deliver_now
  end
end
