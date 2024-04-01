class CreateAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.references :project
      t.references :volunteer
      t.references :user             # Assigner
      t.datetime :ended_at
      t.datetime :started_at
      t.timestamps
    end
  end
end
