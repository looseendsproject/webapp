class CreateVolunteers < ActiveRecord::Migration[7.0]
  def change
    create_table :volunteers do |t|
      t.string :name, null: false
      t.text :description
      t.text :admin_notes
      t.text :contact_info
      t.text :availability
      t.timestamps
    end
  end
end
