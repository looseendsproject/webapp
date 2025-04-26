# frozen_string_literal: true

class FinisherMailer < ApplicationMailer

  after_deliver :record_delivery

  # resource: @finisher
  def welcome
    @message.set_sgid!(redirect_to: "/finisher/new")
    mail(
      to: @resource.user.email,
      subject: "Loose Ends Project Account Created - Next Steps..."
    )
  end

  # resource: @finisher
  def profile_complete
    @message.set_sgid!
    mail(
      to: @resource.user.email,
      subject: "Welcome, Loose Ends Finisher!"
    )
  end

  # resource: @assignment
  def project_check_in
    @message.set_sgid!(redirect_to: "/assignment/#{@resource.id}/check_in",
      expires_in: @expires_in)
    mail(
      to: @resource.finisher.user.email,
      subject: "Tell us how #{@resource.project.name} is going"
    )
  end

  private

  # `message` here is the Mail::Message just delivered
  #
  def record_delivery
    @message.channel = "outbound"
    @message.email_source.attach(io: StringIO.new(message.to_s),
      filename: "source.eml", content_type: "text/plain")
    @message.save!
  end
end
