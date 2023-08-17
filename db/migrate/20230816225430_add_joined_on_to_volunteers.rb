class AddJoinedOnToVolunteers < ActiveRecord::Migration[7.0]
  def change
    add_column :volunteers, :joined_on, :date
    add_index :volunteers, :joined_on
  end
end
