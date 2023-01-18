class CreateAssignmentUpdates < ActiveRecord::Migration[7.0]
  def change
    create_table :assignment_updates do |t|
      t.references :assignment
      t.references :user
      t.text :description
      t.timestamps
    end
  end
end
