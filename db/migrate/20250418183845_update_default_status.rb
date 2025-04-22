class UpdateDefaultStatus < ActiveRecord::Migration[8.0]
  def change
    change_column :projects, :status, :string, null: false, default: "DRAFTED"
  end
end
