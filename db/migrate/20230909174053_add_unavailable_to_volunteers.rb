class AddUnavailableToVolunteers < ActiveRecord::Migration[7.0]
  def change
    add_column :volunteers, :unavailable, :boolean, default: false
  end
end
