class CreateAssessments < ActiveRecord::Migration[7.0]
  def change
    create_table :assessments do |t|
      t.references :skill
      t.references :finisher
      t.integer :rating, null: false
      t.text :description
      t.timestamps
    end
  end
end
