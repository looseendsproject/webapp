class ForwardsMailbox < ApplicationMailbox

  def process
    m = resource.messages.new(channel: "inbound")
    m.email_source.attach(io: StringIO.new(mail.raw_source),
      filename: "source.eml", content_type: "text/plain")
    m.stash_headers(mail)
    m.save!
  end

  private

  def resource
    all_addresses = [mail.to, mail.cc, mail.bcc].flatten.compact
    all_addresses.each do |addr|
      matches = /^(project|finisher)-\w{#{EmailAddressable::LENGTH}}@/.match(addr)
      if matches.present?
        klass = matches[1].titleize.constantize
        record = klass.find_by(inbound_email_address: addr.downcase)
        return record if record.present?
      end
    end

    # Put InboundEmail into "failed" (3) status if no record
    raise ActiveRecord::RecordNotFound
  end

end
