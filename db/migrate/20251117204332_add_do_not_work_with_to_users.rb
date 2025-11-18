class AddDoNotWorkWithToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :do_not_work_with, :boolean, default: false, null: false
  end
end
