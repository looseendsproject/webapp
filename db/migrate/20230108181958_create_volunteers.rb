class CreateFinishers < ActiveRecord::Migration[7.0]
  def change
    create_table :finishers do |t|

      t.string :chosen_name
      t.string :pronouns

      # Email, name, phone
      t.references :user, null: false
      t.text :description, null: false

      # Admin
      t.text :admin_notes
      t.datetime :approved_at

      # Mailing Addrees
      t.string :street
      t.string :street_2
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code

      # Skills
      # Skill - talent level 1, 2, 3
      t.text :other_skills
      t.string :dominant_hand # left or right

      # Products
      # Favorite things to make
      t.text :other_favorites

      t.text :dislikes

      # We'll follow and share
      t.text :social_media

      t.boolean :can_publicize

      # sensitivities
      t.boolean :no_smoke
      t.boolean :no_cats
      t.boolean :no_dogs

      # Terms
      t.boolean :terms_of_use

      t.timestamps
    end
  end
end
