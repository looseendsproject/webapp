# frozen_string_literal: true

class ProjectMailer < ApplicationMailer

  # resource: @assignment
  def alert_manager
    mail(
      to: @resource.project.manager.email,
      subject: "NEEDS ATTENTION: #{@resource.project.name}"
    )
  end
end
