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

  desc "Copy project_notes to notes"
  task copy_project_notes: [:environment] do |_t|
    ActiveRecord::Base.record_timestamps = false
    ProjectNote.all.each do |pn|
      note = Note.create!({
        notable_type: "Project",
        notable_id: pn.project_id,
        user_id: pn.user_id,
        text: pn.description,
        created_at: pn.created_at,
        updated_at: pn.updated_at
      })
      puts "Copied project_note #{pn.id}"
    end
    ActiveRecord::Base.record_timestamps = true
  end

end
