class FinisherMailerPreview < ActionMailer::Preview
  include ActionMailer::Previews
  register_preview_interceptor :setup_preview

  def welcome
    FinisherMailer.with(resource: Finisher.first).welcome
  end

  def profile_complete
    FinisherMailer.with(resource: Finisher.first).profile_complete
  end
end
