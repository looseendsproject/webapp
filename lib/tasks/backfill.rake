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

    # Statuses
    Project.all.each do |project|

      next if Project::STATUSES.include? project.status
      next if ["IN PROCESS", "READY TO MATCH"].include? project.status # for idempotency

      original_status = nil
      begin

        original_status = project.status

        if ["in process", "ready to match"].include?(project.status)
          project.update_column("status", project.status.upcase)
          next
        end

        # Simplest case
        if Project::STATUSES.include?(project.status.upcase)
          project.update_column("status", project.status.upcase)
          next
        end

        # Maps
        project.update_column("status", STATUS_MAPS[project.status])

        puts "#{project.id} #{project.name} #{project.status}"

      rescue
        puts "Invalid status: #{project.status}. Original status: #{original_status}"
      end
    end

    # Substatuses
    Project.where("ready_status IS NOT NULL OR in_process_status IS NOT NULL").each do |project|

      next if Project::STATUSES.include? project.status

      original_substatus = nil
      begin

        original_substatus = [project.in_process_status, project.ready_status]

        if project.status == "IN PROCESS"
          substatus = project.in_process_status.present? ?
            STATUS_MAPS[project.in_process_status] : "CONNECTED"
        end

        if project.status == "READY TO MATCH"
          substatus = project.ready_status.present? ? STATUS_MAPS[project.ready_status] : "NEW"
        end

        raise "NULL substatus for #{project.status}" unless substatus.present?
        compound_status = "#{project.status}: #{substatus}"
        raise "No compound status '#{compound_status}'" \
          unless Project::STATUSES.include?(compound_status)

        project.update_column("status", compound_status)

        puts "#{project.id} #{project.name} #{project.status}"

      rescue StandardError => e
        puts "#{e}: #{compound_status}. \
          Original substatuses: #{original_substatus} \
          Current status: #{project.status}"
      end
    end

    # Gutcheck the backfill in case some threw exceptions
    puts Project.group(:status).count(:status)

  end # convert project status

end
