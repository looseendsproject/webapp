# config/initializers/override_staging_recipient.rb

if ENV['RAILS_ENV_DISPLAY'] == 'staging'
  class OverrideStagingRecipient
    def self.delivering_email(mail)
      original_reipient = mail.to
      mail.to = 'app-staging@looseendsproject.org'
      mail.from = 'app-staging@looseendsproject.org'
      mail.subject = "[#{ENV['RAILS_ENV_DISPLAY'].upcase}] #{mail.subject}"
      mail.body = "[original recipient: #{original_reipient}]\n\n" + mail.body
    end
  end
  ActionMailer::Base.register_interceptor(OverrideStagingRecipient)
end
