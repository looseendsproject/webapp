class ProjectMailerPreview < ActionMailer::Preview
  include ActionMailer::Previews
  register_preview_interceptor :setup_preview

  def alert_manager
    ProjectMailer.with(resource: Assignment.active.first).alert_manager
  end
end
