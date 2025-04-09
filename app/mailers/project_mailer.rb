# frozen_string_literal: true

class ProjectMailer < ApplicationMailer

  def alert_manager
    @message.set_sgid!(redirect_to: "/manage/project/#{@resource.id}", expires_at: nil)
    mail(
      to: @resource.manager.email,
      subject: "NEEDS ATTENTION: #{@resource.name}"
    )
  end
end
