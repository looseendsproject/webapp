# config/initializers/override_staging_recipient.rb

if ENV['RAILS_ENV_DISPLAY'] == 'staging'
  class OverrideStagingRecipient
    def self.delivering_email(mail)
      mail.to = 'app-staging@looseendsproject.org'
      mail.from = 'no-reply-staging@looseendsproject.org'
      mail.subject = "[#{ENV['RAILS_ENV_DISPLAY'].upcase}] #{mail.subject}"
    end
  end
  ActionMailer::Base.register_interceptor(OverrideStagingRecipient)
end
