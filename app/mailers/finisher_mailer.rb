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
      subject: "Tell us how #{@resource.project.name} is going",
      reply_to: assignment_reply_to_email(@resource)
    )
  end

  private

  def assignment_reply_to_email(assignment)
    manager = assignment.project.manager
    if manager.present?
      email_address_with_name(manager.email, manager.name)
    else
      "info@looseendsproject.org"
    end
  end
end
