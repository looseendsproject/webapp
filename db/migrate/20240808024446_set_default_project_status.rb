class SetDefaultProjectStatus < ActiveRecord::Migration[7.0]
  def change
    change_column_default :projects, :status, 'draft'
  end
end
