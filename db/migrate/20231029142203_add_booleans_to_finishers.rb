class AddBooleansToFinishers < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :in_home_pets, :string
    add_column :finishers, :has_smoke_in_home, :boolean, default: false
  end
end
