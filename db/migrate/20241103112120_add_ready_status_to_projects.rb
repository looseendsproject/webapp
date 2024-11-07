class AddReadyStatusToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :ready_status, :string
  end
end
