# frozen_string_literal: true

namespace :email do

  desc "Set inbound_email_address on Project where NULL"
  task inbound_emails: [:environment] do |_t|
    Project.where('inbound_email_address IS NULL').all.each do |p|
      puts p.ensure_inbound_email_address
      p.save!(validate: false)
    end
  end

  desc "Downcase inbound_email_addresses"
  task downcase_inbound_email: [:environment] do |_t|
    Finisher.where.not(inbound_email_address: nil).map do |f|
      f.update_attribute("inbound_email_address", f.inbound_email_address.downcase)
    end

    Project.where.not(inbound_email_address: nil).map do |p|
      p.update_attribute("inbound_email_address", p.inbound_email_address.downcase)
    end
  end

  desc "Reprocess failed InboundEmails"
  task reprocess_failed: [:environment] do |_t|
    ActionMailbox::InboundEmail.where("status > ?", 2).order(id: :asc).each do |inbound|
      begin
        inbound.pending!
        inbound.route
        puts "InboundEmail #{inbound.id}: reprocessed"
      rescue
        puts "InboundEmail #{inbound.id}: missing blob"
        next
      end
    end
  end

  desc "Move Message email source from ActionText to ActiveStorage"
  task move_email_source: [:environment] do |_t|

    # Gotta do this to circumvent ActionText magic
    docs = ActiveRecord::Base.connection.execute("SELECT record_id, body FROM action_text_rich_texts")
    docs.each do |doc|
      message = Message.find(doc["record_id"])
      if message.present?
        message.email_source.attach(io: StringIO.new(doc["body"]),
          filename: "rich_text.eml", content_type: "text/plain")
        message.stash_headers(Mail.from_source doc["body"])
        message.save!
      end
    end
  end

end
