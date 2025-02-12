class FinisherMailerPreview < ActionMailer::Preview

  def welcome
    FinisherMailer.welcome(Finisher.first)
  end

  def profile_complete
    FinisherMailer.profile_complete(Finisher.first)
  end
end
