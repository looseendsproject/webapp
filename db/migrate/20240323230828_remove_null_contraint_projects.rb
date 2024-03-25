class RemoveNullContraintProjects < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:projects, :user_id, true)
  end
end
