# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "info@looseendsproject.org"
  layout "mailer"

  before_action :add_logo!

  private

  def add_logo!
    attachments.inline['looseendslogo.png'] = Rails.root.join('app', 'assets', 'images', 'looseendslogo.png').read
  end
end
