class ChangeVolunteersToFinishers < ActiveRecord::Migration[7.0]
  def change
    rename_table :volunteers, :finishers
    rename_column :assessments, :volunteer_id, :finisher_id
    rename_column :assignments, :volunteer_id, :finisher_id
    rename_column :favorites, :volunteer_id, :finisher_id
  end
end
