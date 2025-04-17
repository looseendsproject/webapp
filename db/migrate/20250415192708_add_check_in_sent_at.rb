class AddCheckInSentAt < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :check_in_sent_at, :datetime
  end
end
