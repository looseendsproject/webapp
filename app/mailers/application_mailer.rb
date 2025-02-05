# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "info@looseendsproject.org"
  layout "mailer"
end
