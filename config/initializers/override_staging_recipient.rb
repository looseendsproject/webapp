# config/initializers/override_staging_recipient.rb

if Rails.env.staging?
  class OverrideStagingRecipient
    def self.delivering_email(mail)
      mail.to = 'app-staging@looseendsproject.org'
      mail.from = 'no-reply-staging@looseendsproject.org'
      mail.subject = "[#{Rails.env.upcase}] #{mail.subject}"
    end
  end
  ActionMailer::Base.register_interceptor(OverrideStagingRecipient)
end
