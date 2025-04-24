class ForwardsMailbox < ApplicationMailbox

  def process
    ActiveRecord::Base.transaction do
      m = resource.messages.create!(channel: "inbound")
      m.email_source.attach(mail.raw_source)
    end
  end

  private

  def resource
    all_addresses = [mail.to, mail.cc, mail.bcc].flatten.compact
    all_addresses.each do |addr|
      matches = /^(\w+)-\w{#{EmailAddressable::LENGTH}}@/.match(addr)
      if matches.present?
        klass = matches[1].titleize.constantize
        record = klass.find_by(inbound_email_address: addr.downcase)
        return record if record.present?
      end
    end

    # Put InboundEmail into "failed" (2) status if no record
    raise ActiveRecord::RecordNotFound
  end

end
