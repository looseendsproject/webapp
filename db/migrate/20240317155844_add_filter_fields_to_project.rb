class AddFilterFieldsToProject < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :in_home_pets, :string
    add_column :projects, :has_smoke_in_home, :boolean, default: false
    add_column :projects, :no_smoke, :boolean
    add_column :projects, :no_cats, :boolean
    add_column :projects, :no_dogs, :boolean
    add_column :projects, :crafter_dominant_hand, :string
  end
end
