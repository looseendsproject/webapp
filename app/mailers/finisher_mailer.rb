# frozen_string_literal: true

class FinisherMailer < ApplicationMailer

  after_deliver :record_delivery

  def welcome
    @message.set_sgid!(redirect_to: "/finisher/new")
    mail(
      to: @resource.user.email,
      subject: "Loose Ends Project Account Created - Next Steps..."
    )
  end

  def profile_complete
    @message.set_sgid!
    mail(
      to: @resource.user.email,
      subject: "Welcome, Loose Ends Finisher!"
    )
  end

  private

  def record_delivery
    @message.update!(channel: 'outbound', content: message.to_s)
  end
end
