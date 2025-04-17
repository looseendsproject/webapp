class FinisherMailerPreview < ActionMailer::Preview
  include ActionMailer::Previews
  register_preview_interceptor :setup_preview

  def welcome
    FinisherMailer.with(resource: Finisher.first).welcome
  end

  def profile_complete
    FinisherMailer.with(resource: Finisher.first).profile_complete
  end

  def project_check_in
    FinisherMailer.with(resource: Assignment.active.first).project_check_in
  end
end
