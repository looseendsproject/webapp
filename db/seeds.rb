require 'csv'
require 'securerandom'
require 'open-uri'

def first_name(name)
  name.split(' ')[0]
end

def last_name(name)
  name.split(' ')[1..-1].join(" ")
end

CSV.foreach(Rails.root.join('db/seed_data/projects.csv'), headers: true) do |row|

  User.where(email: row['Your Email Address'].downcase).destroy_all
  user = User.create({
                email: row['Your Email Address'].downcase,
                first_name: first_name(row['Your Name ']),
                last_name: last_name(row['Your Name ']),
                heard_about_us: '',
                password: SecureRandom.hex
              })

  project = Project.create({
    user_id: user.id,
    name: row["Project description (for instance, sweater, socks, blanket, hat...)"][0, 10],
    craft_type: row['What type of craft project are you submitting?'],
    description: row["Project description (for instance, sweater, socks, blanket, hat...)"]
  })

  downloaded_image = URI.parse("https://media.istockphoto.com/id/508030424/photo/childs-male-sweater-isolated-on-white.jpg?s=1024x1024&w=is&k=20&c=bREIU_JQPWQv9Drzb-hyX4aQ9ND86oqE6I_J82y8Ehs=").open



  project.project_images.attach(
    io:  downloaded_image,
    filename: 'project_image.jpg'
  )



    # "status"
    # "name"
    # "description"
    # "street"
    # "street_2"
    # "city"
    # "state"
    # "country"
    # "postal_code"
    # "craft_type"
    # "has_pattern"
    # "material_type"
    # "crafter_name"
    # "crafter_description"
    # "recipient_name"
    # "more_details"
    # "can_publicize"
    # "terms_of_use"
    # "created_at"
    # "updated_at"
  # })
end