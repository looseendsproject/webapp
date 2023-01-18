class CreateTalents < ActiveRecord::Migration[7.0]
  def change
    create_table :talents do |t|
      t.references :skill
      t.references :volunteer
      t.integer :rating
      t.timestamps
    end
  end
end
