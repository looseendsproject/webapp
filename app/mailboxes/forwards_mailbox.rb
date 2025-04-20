class ForwardsMailbox < ApplicationMailbox

  def process
    m = resource.messages.new
    m.content = mail.raw_source # content is not a db column
    m.save!
  end

  private

  def resource
    mail.to.each do |to|
      matches = /^(\w+)-\w{#{EmailAddressable::LENGTH}}@/.match(to)
      if matches.present?
        klass = matches[1].titleize.constantize
        record = klass.find_by(inbound_email_address: to.downcase)
        return record if record.present?
      end
    end

    # Put InboundEmail into "failed" (2) status if no record
    raise ActiveRecord::RecordNotFound
  end

end
