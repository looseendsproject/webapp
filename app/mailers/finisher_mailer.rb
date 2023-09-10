class FinisherMailer < ActionMailer::Base

  layout 'mailer'

  def welcome (finisher)
    @finisher = finisher
    mail(
      :from => "info@looseendsproject.org",
      :to => finisher.user.email,
      :subject => "Welcome to Loose Ends"
    )
  end

end