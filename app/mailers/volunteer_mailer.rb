class VolunteerMailer < ActionMailer::Base

  layout 'mailer'

  def welcome (volunteer)
    mail(
      :from => "info@looseendsproject.org",
      :to => volunteer.user.email,
      :subject => "Welcome to Loose Ends"
    )
  end

end