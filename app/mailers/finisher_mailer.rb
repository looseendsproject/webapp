# frozen_string_literal: true

class FinisherMailer < ApplicationMailer

  def welcome
    @message.set_sgid!(link_action: "/finisher/new")
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
end
