class CreateFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :favorites do |t|
      t.references :product
      t.references :volunteer
      t.timestamps
    end
  end
end
