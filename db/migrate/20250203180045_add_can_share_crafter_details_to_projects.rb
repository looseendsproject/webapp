class AddCanShareCrafterDetailsToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :can_share_crafter_details, :boolean, default: false
  end
end
