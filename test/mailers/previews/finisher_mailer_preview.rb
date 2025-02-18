class FinisherMailerPreview < ActionMailer::Preview
  include ActionMailer::Previews
  register_preview_interceptor :setup_preview

  def welcome
    FinisherMailer.welcome(Finisher.first)
  end

  def profile_complete
    FinisherMailer.profile_complete(Finisher.first)
  end
end
