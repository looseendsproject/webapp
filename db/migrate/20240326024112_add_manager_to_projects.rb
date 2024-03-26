class AddManagerToProjects < ActiveRecord::Migration[7.0]
  def change
    add_reference :projects, :manager, foreign_key: { to_table: :users }
    add_column :users, :is_project_manager, :boolean
  end
end
