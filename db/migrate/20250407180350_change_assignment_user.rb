class ChangeAssignmentUser < ActiveRecord::Migration[8.0]
  def change
    rename_column :assignments, :user_id, :created_by
  end
end
