class AddInProcessStatusToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :in_process_status, :string
  end
end
