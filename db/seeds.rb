# frozen_string_literal: true

require "csv"
require "open-uri"

def first_name(name)
  name.split[0]
end

def last_name(name)
  name.split[1..].join(" ")
end

# Track created records
created_projects = []
created_finishers = []

# Seed Projects
Rails.logger.debug "Seeding projects..."
CSV.foreach(Rails.root.join("db/seed_data/projects.csv"), headers: true) do |row|
  # Skip if user already exists, but continue with next record
  next if User.exists?(email: row["email"])

  begin
    user = User.create!(
      email: row["email"],
      password: SecureRandom.hex,
      first_name: first_name(row["crafter_name"]),
      last_name: last_name(row["crafter_name"]),
      heard_about_us: "CSV Import"
    )

    project = Project.new(
      user: user,
      name: row["name"],
      phone_number: row["phone_number"],
      description: row["description"],
      more_details: row["more_details"],
      status: row["status"],
      street: row["street"],
      street_2: row["street_2"],
      city: row["city"],
      state: row["state"],
      country: row["country"],
      postal_code: row["postal_code"],
      craft_type: row["craft_type"],
      has_pattern: row["has_pattern"],
      material_type: row["material_type"],
      crafter_name: row["crafter_name"],
      crafter_description: row["crafter_description"],
      crafter_dominant_hand: row["crafter_dominant_hand"],
      recipient_name: row["recipient_name"],
      can_publicize: row["can_publicize"],
      terms_of_use: row["terms_of_use"],
      no_smoke: row["no_smoke"],
      no_cats: row["no_cats"],
      no_dogs: row["no_dogs"],
      has_smoke_in_home: row["has_smoke_in_home"],
      in_home_pets: eval(row["in_home_pets"])
    )

    # Attach a default project image before saving
    downloaded_image = URI.parse("https://media.istockphoto.com/id/508030424/photo/childs-male-sweater-isolated-on-white.jpg?s=1024x1024&w=is&k=20&c=bREIU_JQPWQv9Drzb-hyX4aQ9ND86oqE6I_J82y8Ehs=").open
    project.project_images.attach(
      io: downloaded_image,
      filename: "project_image.jpg"
    )

    project.save!
    created_projects << project
    Rails.logger.debug { "Created project: #{project.name}" }
  rescue StandardError => e
    Rails.logger.debug { "Error creating project for #{row["email"]}: #{e.message}" }
  end
end

# Seed Finishers
Rails.logger.debug "Seeding finishers..."
CSV.foreach(Rails.root.join("db/seed_data/finishers.csv"), headers: true) do |row|
  # Skip if user already exists, but continue with next record
  next if User.exists?(email: row["email"])

  begin
    user = User.create!(
      email: row["email"],
      password: SecureRandom.hex,
      first_name: first_name(row["chosen_name"]),
      last_name: last_name(row["chosen_name"]),
      heard_about_us: "CSV Import"
    )

    finisher = Finisher.create!(
      user: user,
      chosen_name: row["chosen_name"],
      pronouns: row["pronouns"],
      phone_number: row["phone_number"],
      description: row["description"],
      street: row["street"],
      street_2: row["street_2"],
      city: row["city"],
      state: row["state"],
      country: row["country"],
      postal_code: row["postal_code"],
      other_skills: row["other_skills"],
      other_favorites: row["other_favorites"],
      dislikes: row["dislikes"],
      social_media: row["social_media"],
      can_publicize: row["can_publicize"],
      dominant_hand: row["dominant_hand"],
      no_smoke: row["no_smoke"],
      no_cats: row["no_cats"],
      no_dogs: row["no_dogs"],
      has_smoke_in_home: row["has_smoke_in_home"],
      terms_of_use: row["terms_of_use"],
      has_workplace_match: row["has_workplace_match"],
      has_volunteer_time_off: row["has_volunteer_time_off"],
      workplace_name: row["workplace_name"],
      in_home_pets: eval(row["in_home_pets"]),
      has_taken_ownership_of_profile: true,
      unavailable: row["unavailable"]
    )
    created_finishers << finisher
    Rails.logger.debug { "Created finisher: #{finisher.chosen_name}" }
  rescue StandardError => e
    Rails.logger.debug { "Error creating finisher for #{row["email"]}: #{e.message}" }
  end
end

Rails.logger.debug "\nSeeding completed!"
Rails.logger.debug { "Created #{created_projects.length} projects" }
Rails.logger.debug { "Created #{created_finishers.length} finishers" }
