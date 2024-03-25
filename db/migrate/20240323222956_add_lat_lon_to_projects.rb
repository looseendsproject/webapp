class AddLatLonToProjects < ActiveRecord::Migration[7.0]
    def change
      add_column :projects, :latitude, :float
      add_index :projects, :latitude
      add_column :projects, :longitude, :float
      add_index :projects, :longitude
  end
end
