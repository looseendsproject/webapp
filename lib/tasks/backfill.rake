# frozen_string_literal: true

namespace :backfill do

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
      "drafted" => "PROPOSED",
      "DRAFTED" => "PROPOSED",
      "submitted via google" => "PROPOSED",
      "project confirm email sent" => "WAITING PROJECT CONFIRMATION",
      "project accepted/waiting on terms" => "ACCEPTED WAITING TERMS",
      "finished/not returned" => "FINISHED NOT RETURNED",
      "unresponsive" => "WILL NOT DO",
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
    TEST_RUN = false # set to true to not persist

    Project.all.each do |project|
      next if Project::STATUSES.values.include? project.status

      original_status = "#{project.status}, #{project.ready_status}, #{project.in_process_status}"
      status = nil

      # in process requires a substatus
      if project.status == "in process"
        status = "IN PROCESS: " + (project.in_process_status.present? ?
          STATUS_MAPS[project.in_process_status] : "CONNECTED")
      end

      # ready to match requires substatus
      if project.status == "ready to match"
        status = "READY TO MATCH: " + (project.ready_status.present? ?
          STATUS_MAPS[project.ready_status] : "NEW")
      end

      # Simple case -- just upcase the string
      if status.blank? && Project::STATUSES.values.include?(project.status.upcase)
        status = project.status.upcase
      end

      # Map from one value to another
      if status.blank?
        status = STATUS_MAPS[project.status]
      end

      if Project::STATUSES.values.include?(status)
        project.update_column("status", status) unless TEST_RUN
        puts "#{project.id} #{project.name} #{status}"
      else
        puts "Invalid status: #{status}. Original status: #{original_status}"
      end
    end # project loop

    # Gutcheck the backfill in case some threw exceptions
    puts Project.group(:status).count(:status)
  end # convert project status

end
