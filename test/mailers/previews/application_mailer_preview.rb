class ApplicationMailerPreview < ActionMailer::Preview
  include ActionMailer::Previews
  register_preview_interceptor :setup_preview

  def error
    ApplicationMailer.error(to: User.first.email)
  end
end
