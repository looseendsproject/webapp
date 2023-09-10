class AddJoinedOnToVolunteers < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :joined_on, :date
    add_index :finishers, :joined_on
  end
end
