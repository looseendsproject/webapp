class RequireImagesIfAvailable < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :has_materials, :string
  end
end
