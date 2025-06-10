class AddDominantHandToProjectWithDefault < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :dominant_hand, :string, default: 'unknown'
  end
end
