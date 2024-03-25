class CreateProjectNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :project_notes do |t|
      t.references :project
      t.references :user
      t.text :description
      t.timestamps
    end
  end
end
