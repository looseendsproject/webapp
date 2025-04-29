class DropSubstatuses < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :ready_status
    remove_column :projects, :in_process_status
  end
end
