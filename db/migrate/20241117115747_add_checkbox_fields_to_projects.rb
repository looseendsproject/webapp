class AddCheckboxFieldsToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :joann_helped, :boolean, default: false
    add_column :projects, :urgent, :boolean, default: false
    add_column :projects, :influencer, :boolean, default: false
    add_column :projects, :group_project, :boolean, default: false
    add_column :projects, :press, :boolean, default: false
    add_column :projects, :privacy_needed, :boolean, default: false

    # Associated fields
    add_reference :projects, :group_manager, foreign_key: { to_table: :finishers }
    add_column :projects, :press_region, :string
    add_column :projects, :press_outlet, :string
  end
end
