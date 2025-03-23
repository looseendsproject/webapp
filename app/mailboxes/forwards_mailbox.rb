class ForwardsMailbox < ApplicationMailbox

  def process
    project = User.find_by(email: original_sender)&.finisher&.projects&.first

    if project.present?
      m = project.messages.new
      m.content = mail.raw_source
      m.save!
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def original_sender
    senders = mail.raw_source.scan(/^From: (.+)$/)
    /<(\S+)>/.match(senders.last[0]).captures
  end
end
