class FinisherCheckIn < ActiveRecord::Migration[8.0]
  def change
    add_column :finishers, :check_in_interval, :integer,
      null: true # most will default to Assignment::DEFAULT_CHECK_IN_INTERVAL
  end
end
