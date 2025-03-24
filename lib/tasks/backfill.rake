# frozen_string_literal: true

namespace :backfill do
  desc "Set inbound_email_address on Project where NULL"
  task inbound_emails: [:environment] do |_t|
    Project.where('inbound_email_address IS NULL').all.each do |p|
      puts p.ensure_inbound_email_address
      p.save!(validate: false)
    end
  end
end
