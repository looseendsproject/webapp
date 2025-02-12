module Devise
  class MailerPreview< ActionMailer::Preview

    include Rails.application.routes.url_helpers
    include Rails.application.routes.mounted_helpers

    def confirmation_instructions
      Devise::Mailer.confirmation_instructions(User.first, "faketoken")
    end

    def reset_password_instructions
      Devise::Mailer.reset_password_instructions(User.first, "faketoken")
    end

  end
end
