class FinisherMailer < ActionMailer::Base

  layout 'mailer'

  def welcome (finisher)
    @finisher = finisher
    mail(
      :from => "info@looseendsproject.org",
      :to => finisher.user.email,
      :subject => "Loose Ends Project Account Created - Next Steps..."
    )
  end

  def profile_complete (finisher)
    @finisher = finisher
    mail(
      :from => "info@looseendsproject.org",
      :to => finisher.user.email,
      :subject => "Welcome, Loose Ends Finisher!"
    )
  end

end