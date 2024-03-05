class AddEagerToFinishers < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :eager, :boolean, default: false
  end
end
