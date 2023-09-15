class AddLatitudeAndLongitudeToFinisher < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :latitude, :float
    add_index :finishers, :latitude
    add_column :finishers, :longitude, :float
    add_index :finishers, :longitude
  end
end
