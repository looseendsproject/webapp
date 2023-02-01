class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.references :user, null: false
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: 'new'
      t.string :street
      t.string :line_2
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.string :crafter_name
      t.string :recipient_name
      t.text :more_about_material
      t.text :more_about_project
      t.text :more_about_crafter
      t.boolean :can_share_project_info
      t.boolean :can_share_crafter_info
      t.timestamps
    end
  end
end
