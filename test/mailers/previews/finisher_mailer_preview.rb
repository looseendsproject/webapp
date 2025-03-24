class FinisherMailerPreview < ActionMailer::Preview
  include ActionMailer::Previews
  register_preview_interceptor :setup_preview

  def welcome
    FinisherMailer.welcome(Finisher.fake)
  end

  def profile_complete
    FinisherMailer.profile_complete(Finisher.fake)
  end
end
