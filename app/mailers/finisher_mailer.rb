# frozen_string_literal: true

class FinisherMailer < ApplicationMailer

  after_deliver :record_delivery

  def welcome(finisher)
    @finisher = finisher
    mail(
      from: "info@looseendsproject.org",
      to: finisher.user.email,
      subject: "Loose Ends Project Account Created - Next Steps..."
    )
  end

  def profile_complete(finisher)
    @finisher = finisher
    mail(
      from: "info@looseendsproject.org",
      to: finisher.user.email,
      subject: "Welcome, Loose Ends Finisher!"
    )
  end

  private

  def record_delivery
    @finisher.messages.create!(channel: 'outbound', content: message.to_s)
  end
end
