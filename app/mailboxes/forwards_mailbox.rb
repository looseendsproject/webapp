class ForwardsMailbox < ApplicationMailbox
  before_processing :require_resource

  def process
    puts resource
  end

  private

  def require_resource
  end

  def resource
    @resource ||= User.find_by(email_address: mail.from)
  end
end
