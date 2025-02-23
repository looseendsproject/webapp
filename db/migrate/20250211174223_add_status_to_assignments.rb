class AddStatusToAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :assignments, :status, :text
  end
end
