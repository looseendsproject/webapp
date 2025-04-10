class Notes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.belongs_to :notable, polymorphic: true
      t.text :description
      t.string :visibility, null: false, default: 'manager'
      t.integer :rating # so we can count good/bad check-ins
      t.timestamps
    end

    drop_table :assignment_updates, if_exists: true
  end
end
