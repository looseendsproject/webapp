class AddMaterialBrandToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :material_brand, :text
  end
end
