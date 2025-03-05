class AddHasVolunteerTimeOffToFinishers < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :has_volunteer_time_off, :boolean
  end
end
