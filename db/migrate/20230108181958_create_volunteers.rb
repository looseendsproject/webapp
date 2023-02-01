class CreateVolunteers < ActiveRecord::Migration[7.0]
  def change
    create_table :volunteers do |t|
      t.references :user, null: false
      t.text :description, null: false
      t.text :admin_notes
      t.string :street
      t.string :line_2
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.text :availability
      t.text :likes
      t.text :dislikes
      t.text :social_media
      t.boolean :can_handle_smoke
      t.datetime :approved_at
      t.timestamps
    end
  end
end
