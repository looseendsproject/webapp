class AddCanUseFirstNameToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :can_use_first_name, :boolean, default: false
  end
end
