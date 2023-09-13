class AddHasCompletedProfileToFinishers < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :has_completed_profile, :boolean, default: false
    add_column :finishers, :has_taken_ownership_of_profile, :boolean, default: false
  end
end
