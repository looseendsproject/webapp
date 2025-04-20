class ForwardsMailbox < ApplicationMailbox

  def process
    m = resource.messages.new
    m.content = mail.raw_source # content is not a db column
    m.save!
  end

  private

  # BUG Gotta look for inbound_email_address in to:, cc:, and bcc: arrays
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
