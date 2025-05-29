class SetDefaultCrafterDetails < ActiveRecord::Migration[8.0]
  def change
    change_column_default :projects, :can_share_crafter_details, from: false, to: true
  end
end
