class AddDominantHandToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :dominant_hand, :string, null: false, default: 'unknown', comment: 'Dominant hand of the project owner'
  end
end
