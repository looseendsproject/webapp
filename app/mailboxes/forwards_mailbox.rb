class ForwardsMailbox < ApplicationMailbox

  def process
    m = resource.messages.new
    m.content = mail.raw_source # content is not a db column
    m.save!
  end

  private

  def resource
    matches = /^(\w+)-\w{#{EmailAddressable::LENGTH}}@/.match(mail.to.first)
    if matches.present?
      klass = matches[1].constantize
      record = klass.find_by(inbound_email_address: mail.to.first)
    end

    # Exception will kick InboundEmail into "failed" status until incinerated
    raise ActiveRecord::RecordNotFound unless record.present?
    record
  end
end
