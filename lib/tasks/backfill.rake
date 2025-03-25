# frozen_string_literal: true

namespace :backfill do

  desc "Set inbound_email_address on Project where NULL"
  task inbound_emails: [:environment] do |_t|
    Project.where('inbound_email_address IS NULL').all.each do |p|
      puts p.ensure_inbound_email_address
      p.save!(validate: false)
    end
  end

  desc "Set message.channel"
  task message_channel: [:environment] do |_t|
    Message.where('channel IS NULL').update_all(channel: 'inbound')
  end

  desc "Update message description"
  task message_description: [:environment] do |_t|
    Message.all.each do |m|
      m.description = nil
      m.save!
    end
  end
end
