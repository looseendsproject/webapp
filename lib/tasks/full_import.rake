# frozen_string_literal: true

# This is the ugliest script I have ever created.  I am not proud.

namespace :full_import do

  # Imports most of Google Sheet data so we can stop using it...

  ## Edit sheet prior to dumping CSV
    # One Finisher email/name per cell
    # One PO email/name per cell
    # Multiple photos separated with ", " or " ", not "\n" or nil
    # Add COUNTRY column for Project
    # Phone numbers must be 10 digits
    # Email addresses must be valid

  ## Prepare CSV by hand
    # Remove pre-header rows (14)
    # Remove trailing empty columns

  # < CSV::Row
  #   date: "9/23/2024 16:01:06"
  #   last_f_contact: "6/23/2025"
  #   nil: "G"
  #   status: "HUMMING ALONG (BOTH REPLIED)"
  #   notes: "6/23: 1 5/15: \"1\""
  #   terms: "P"
  #   brands: "Red Heart"
  #   project_name: "Child's blanket"
  #   finisher_name: "Re Dacted"
  #   finisher_address: "1111 94A ave NE"
  #   finisher_city: "Edmonton"
  #   finisher_state: "AB"
  #   finisher_country: "Canada"
  #   finisher_zip: "T6B0Z6"
  #   finisher_email: "finisher@gmail.com"
  #   finisher_phone: "5555551212"
  #   project_owners_name: "Re Dacted"
  #   project_owner_address: "2222 46B Street NE"
  #   city: "Edmonton"
  #   state: "AB"
  #   zip: "T6A 1Z4"
  #   project_owner_country: "Canada"
  #   project_owner_email: "owner@gmail.com"
  #   project_owner_phone: "5555551212"
  #   original_crafter: "Re Dacted"
  #   who_for: "Granddaughters"
  #   project_description: "Blanket for each granddaughter"
  #   pattern: "No"
  #   project_photo: "https://drive.google.com/open?id=1rjYWrhNdAX_TGGqjiwVILCPUG6kQPm1L, https://drive.google.com/open?id=1bgxGBAKdWVtqn1tWtjmBJZ_1YwJV4AzY"
  #   materials_photo: "https://drive.google.com/open?id=1Vc5bt5TZCrNFryT7TZN8nzIZii19Acqe"
  #   project_info: "Long string of text..."
  #   pattern_photo: nil
  #   crafter_bio: "Long string of text..."
  #   crafter_picture: "https://drive.google.com/open?id=11FvNI3S9pYqlq5HJht0QgBVEGIWZSjmJ"
  #   craft: "Not sure if it is knitting or crocheting"
  #   material: "Synthetic (Nylon, Polyester, Acrylic, etc)"
  #   referred: "Through a friend who follows you on Instagram"
  #   terms: "I agree."
  #   project_pic_ok_to_use: "Yes"
  #   crafter_photo_ok_to_use: "Yes"
  #   pets_ok: "Yes"
  #   po_pets: "No"
  #   po_smoker: "No"
  #   right_left: "Right"
  #   finisher_feedback_form_sent: nil
  #   po_feedback_form_sent: nil
  #   po_feedback_form_recd: nil
  # >

  CSV_KEY = "latest_sheet_dump.csv"
  BUCKET = "looseendsproject-" + ENV["RAILS_ENV_DISPLAY"]
  TMPFILE = Rails.root.join("tmp", "full_import.csv")
  DEFAULT_PASSWORD = "CREATED_FROM_IMPORT"

  desc "Import Google Sheet data"
  task import: [:environment] do |_t|
    MANAGER_JEAN = User.find(108513)

    set_up_logger("rake full_import:import")

    download_csv(CSV_KEY)
    successful_imports = 0
    total_rows = 0
    start_time = Time.zone.now
    failed_rows = []

    CSV.foreach(TMPFILE,
      :headers => true,
      :header_converters => :symbol) do |row|

      total_rows += 1
      @row = row

      next unless [
        "HUMMING ALONG (BOTH REPLIED)",
        "IN PROCESS / from Masey",
        "IN PROCESS"
      ].include? @row[:status]

      log "\nSTARTING import for project \"#{@row[:project_name]}\""

      if @row[:project_owner_email].blank? || @row[:finisher_email].blank?
        log "FAILED.  Missing email address for \"#{@row[:project_name]}\""
        failed_rows.append @row[:project_name]
        next
      end

      po_user, finisher_user = create_users!

      if po_user.blank? || finisher_user.blank?
        log "FAILED.  Could not create users for \"#{@row[:project_name]}\""
        failed_rows.append @row[:project_name]
        next
      end

      project = create_project!(po_user)

      if project.blank?
        log "FAILED. Could not create project \"#{@row[:project_name]}\""
        failed_rows.append @row[:project_name]
        next
      end

      create_project_note!(project, @row[:notes])
      create_project_note!(project, "Project originated at: #{@row[:date]}")

      finisher = create_finisher!(finisher_user)

      if finisher.blank?
        log "FAILED.  Could not create Finisher #{@row[:finisher_name]}"
        failed_rows.append @row[:project_name]
        next
      end

      create_assignment!(project, finisher)

      get_images(project)

      successful_imports += 1
      log "FINISHED importing project \"#{project.name}\""
    end

    end_time = Time.zone.now
    log "\nIMPORTED #{successful_imports} of #{total_rows} Projects in #{(end_time - start_time) / 60} minutes"
    log "\nFAILED IMPORTS\n  -- #{failed_rows.join("\n  -- ")}"
  end

  def download_csv(key)
    s3 = Aws::S3::Client.new(
      :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
      :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"])
    resp = s3.get_object(response_target: TMPFILE, bucket: BUCKET, key: CSV_KEY)
    log("Downloaded S3 object #{BUCKET}/#{CSV_KEY}")
  end

  def set_up_logger(preamble)
    line = preamble + " " + Time.zone.now.iso8601
    puts line
    @logger = JobLog.create!(output: "#{line}\n")
  end

  def log(line)
    puts line
    @logger.update!(output: @logger.reload.output + line + "\n")
  end

  def create_users!
    # Project owner
    begin
      po = User.find_or_initialize_by(email: @row[:project_owner_email].strip.downcase)
      name_tokens = @row[:project_owners_name].split(" ")
      po.first_name = name_tokens[0] || "ERROR"
      po.last_name = name_tokens[1] || "ERROR"
      po.phone = pad_phone(@row[:project_owner_phone])
      po.role = "user"
      po.heard_about_us = "IMPORT"
      po.password = DEFAULT_PASSWORD
      po.password_confirmation = DEFAULT_PASSWORD
      po.skip_confirmation!
      po.save!
      log("CREATED Project Owner user #{po.id} #{@row[:project_owners_name]}")
    rescue StandardError => e
      log("ERROR #{e} #{@row[:project_owner_email]}")
      return nil
    end

    # Finisher
    begin
      finisher = User.find_or_initialize_by(email:  @row[:finisher_email].strip.downcase)
      name_tokens = @row[:finisher_name].split(" ")
      finisher.first_name = name_tokens[0] || "ERROR"
      finisher.last_name = name_tokens[1] || "ERROR"
      finisher.phone = pad_phone(@row[:finisher_phone])
      finisher.role = "user"
      finisher.heard_about_us = "IMPORT"
      finisher.password = DEFAULT_PASSWORD
      finisher.password_confirmation = DEFAULT_PASSWORD
      finisher.skip_confirmation!
      finisher.save!
      log("CREATED Finisher user #{finisher.id} #{@row[:finisher_name]}")
    rescue StandardError => e
      log("ERROR #{e} #{@row[:finisher_email]}")
      return nil
    end

    return [po, finisher]
  end

  def create_project!(po)
    project = Project.find_or_initialize_by(name: "#{@row[:project_name]} [IMPORT]")

    project.assign_attributes(
      user_id: po.id,
      status: "IN PROCESS: UNDERWAY",
      description: @row[:project_description],
      street: @row[:project_owner_address],
      street_2: nil,
      city: @row[:city],
      state: @row[:state],
      country: @row[:project_owner_country] || 'US',
      postal_code: @row[:zip],
      craft_type: @row[:craft],
      has_pattern: @row[:pattern],
      material_type: @row[:material],
      crafter_name: @row[:original_crafter],
      crafter_description: @row[:crafter_bio],
      recipient_name: @row[:who_for],
      more_details: nil,
      can_publicize: nil,
      terms_of_use: @row[:terms] && @row[:terms][0] == "Y" ? true : nil,
      phone_number: pad_phone(@row[:project_owner_phone]),
      in_home_pets: nil,
      has_smoke_in_home: @row[:po_smoker] && @row[:po_smoker] =~ /No/i ? false : nil,
      no_smoke: nil,
      no_cats: nil,
      no_dogs: nil,
      crafter_dominant_hand: nil,
      manager: MANAGER_JEAN,
      joann_helped: nil,
      urgent: nil,
      influencer: nil,
      group_project: nil,
      press: nil,
      privacy_needed: nil,
      group_manager_id: nil,
      press_region: nil,
      press_outlet: nil,
      can_use_first_name: nil,
      can_share_crafter_details: nil,
      material_brand: @row[:brands],
      has_materials: nil,
      needs_attention: nil,
      dominant_hand: @row[:right_left] || 'unknown'
    )
    project.ensure_inbound_email_address

    begin
      project.save! validate: false
      log "CREATED Project \"#{project.name}\""
      return project
    rescue StandardError => e
      log "FAILED Project \"#{project.name}\", #{e}"
      return nil
    end
  end

  def pad_phone(str)
    return "ERROR     " unless str.present?
    return sprintf("%10s", result) unless str.length >= 10
    str
  end

  def create_project_note!(project, text)
    note = Note.find_or_initialize_by(
      notable: project,
      text: text,
      user: MANAGER_JEAN
    )

    begin
      note.save!
      log "CREATED Project Note for #{project.name}"
      return note
    rescue StandardError => e
      log "ERROR Project Note: #{e}"
      return nil
    end
  end

  def create_finisher!(user)
    finisher = Finisher.find_or_initialize_by(user_id: user.id)
    finisher.assign_attributes(
      chosen_name: "#{user.first_name} #{user.last_name}",
      description: finisher.description || "default finisher description",
      approved_at: Time.zone.now,
      street: @row[:finisher_address],
      city: @row[:finisher_city],
      state: @row[:finisher_state],
      country: @row[:finisher_country],
      postal_code: @row[:finisher_zip],
      phone_number: pad_phone(@row[:finisher_phone])
    )

    begin
      finisher.save!
      log "CREATED Finisher for User #{finisher.name}"
      return finisher
    rescue StandardError => e
      log "ERROR creating Finisher: #{e}"
      return nil
    end
  end

  def create_assignment! (project, finisher)
    def parse_date(str)
      return nil if str.blank?
      month_str, day_str, year_str = str.split("/")
      year = year_str.to_i == 2024 ? 2024 : 2025 # HACK HACK HACK
      return Date.new(year, month_str.to_i, day_str.to_i).beginning_of_day
    end

    assignment = Assignment.find_or_initialize_by(project_id: project.id, finisher_id: finisher.id)
    assignment.assign_attributes(
      creator: MANAGER_JEAN,
      status: "accepted",
      last_contacted_at: parse_date(@row[:last_f_contact])
    )

    begin
      assignment.save!
      log "CREATED Assignment for Project \"#{project.name}\" to Finisher #{finisher.name}"
      return assignment
    rescue StandardError => e
      log "ERROR creating Assignment: #{e}"
      return nil
    end
  end

  def get_images(project)

    def extract_ids(str, type)
      return unless str.present?
      str.split(/(,|, | )/).each do |uri|
        begin
          query_str = URI(uri).query
        rescue StandardError => e
          log "ERROR parsing uri \"#{uri}\": #{e}"
          next
        end
        next unless query_str.present?
        id = query_str.split("=")[1]
        @image_ids[id] = type
      end
    end

    def download(key)
      uri = "https://drive.usercontent.google.com/download?id=#{key}&confirm=xxx"

      begin
        stream = OpenURI.open_uri(uri)
        if stream.content_type == "text/html"
          log "ERROR downloading: content_type text/html"
          return nil
        end
      rescue StandardError => e
        log "ERROR downloading #{@image_ids[key]} #{key}: #{e}"
        return nil
      end

      tmpfile = Tempfile.create
      begin
        tmpfile.write(stream.read.force_encoding(Encoding::UTF_8))
        log "DOWNLOADED #{key} #{@image_ids[key]}"
        return tmpfile
      rescue StandardError => e
        File.unlink(tmpfile.path)
        log "ERROR downloading #{key}: #{e}"
        return nil
      end
    end

    def attach(project, tmpfile, key, type)
      io = File.open(tmpfile.path)
      case type
      when :project
        project.project_images.attach(io: io, filename: key)
      when :materials
        project.material_images.attach(io: io, filename: key)
      when :pattern
        project.pattern_files.attach(io: io, filename: key)
      when :crafter
        project.crafter_images.attach(io: io, filename: key)
      end

      project.save(validate: false)
      File.unlink(tmpfile.path)
      log "ATTACHED #{type} #{key} to Project #{project.id}"
    end

    @image_ids = {}
    extract_ids(@row[:project_photo], :project)
    extract_ids(@row[:materials_photo], :materials)
    extract_ids(@row[:pattern_photo], :pattern)
    extract_ids(@row[:crafter_picture], :crafter)

    @image_ids.keys.each do |key|
      tmpfile = download(key)
      next unless tmpfile.present? && tmpfile.size > 0
      attach(project, tmpfile, key, @image_ids[key])
    end

  end
end
