class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.references :user, null: false
      t.string :status, null: false, default: 'new'
      t.datetime :highlighted_at

      t.timestamps
    end
  end
end
