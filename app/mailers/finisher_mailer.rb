# frozen_string_literal: true

class FinisherMailer < ApplicationMailer

  after_deliver :record_delivery

  def welcome(finisher)
    @finisher = finisher
    @method = "welcome"
    mail(
      from: "info@looseendsproject.org",
      to: finisher.user.email,
      subject: "Loose Ends Project Account Created - Next Steps..."
    )
  end

  def profile_complete(finisher)
    @finisher = finisher
    @method = "profile_complete"
    mail(
      from: "info@looseendsproject.org",
      to: finisher.user.email,
      subject: "Welcome, Loose Ends Finisher!"
    )
  end

  private

  def record_delivery
    @finisher.messages.create!(channel: 'outbound',
      content: message.to_s, description: "#{mail.delivery_handler}.#{@method}")
  end
end
