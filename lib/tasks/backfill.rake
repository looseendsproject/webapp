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

  desc "Set Project.needs_attention for existing negative notes"
  task needs_attention: [:environment] do |_t|
    Note.where(sentiment: "not_great").each do |note|
      note.notable.project.update!(needs_attention: "negative_sentiment")
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

  desc "Convert Project status values"
  task convert_project_status: [:environment] do |_t|

    STATUS_MAPS = {
      "submitted via google" => "DRAFTED",
      "project confirm email sent" => "WAITING PROJECT CONFIRMATION",
      "project accepted/waiting on terms" => "ACCEPTED WAITING TERMS",
      "finished/not returned" => "FINISHED NOT RETURNED",
      "unresponsive" => "PO UNRESPONSIVE",
      "waiting for return to rematch" => "READY TO MATCH: REMATCH REQUESTED",
      "weird circumstance" => "TEST",
      "new" => "NEW",
      "new - additional attempt" => "ADDITIONAL ATTEMPT",
      "new - needs to go on facebook" => "NEW",
      "old - needs match with a second skill" => "NEEDS SECOND SKILL",
      "old - finisher requested rematch" => "REMATCH REQUESTED",
      "connected (both finisher and po have responded)" => "CONNECTED",
      "po still has project" => "WAITING HANDOFF",
      "humming along" => "UNDERWAY",
      "check in" => "UNDERWAY",
      "po out of touch" => "PO UNRESPONSIVE"
    }

    # Statuses
    Project.all.each do |project|
      puts "#{project.id} #{project.name} \
        #{project.status} #{project.ready_status} #{project.in_process_status}"

      begin

        if ["in process", "ready to match"].include?(project.status)
          project.update_attribute("status", project.status.upcase)
          next
        end

        # Simplest case
        if Project::STATUSES.include?(project.status.upcase)
          project.update_attribute("status", project.status.upcase)
          next
        end

        # Maps
        project.update_attribute("status", STATUS_MAPS[project.status])
      end
    end

    # Substatuses
    Project.where("ready_status IS NOT NULL OR in_process_status IS NOT NULL").each do |project|
      puts "#{project.id} #{project.name} \
        #{project.status} #project{ready_status} #{project.in_process_status}"

      begin
        if project.status == "IN PROCESS" && project.in_process_status.present?
          substatus = STATUS_MAPS[project.in_process_status]
        end

        if project.status == "READY TO MATCH" && project.ready_status.present?
          substatus = STATUS_MAPS[project.ready_status]
        end
        project.update_attribute("status", "#{status}: #{substatus}")
      end
    end

  end # convert project status

end
