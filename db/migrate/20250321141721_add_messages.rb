class AddMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.string :description
      t.belongs_to :messageable, polymorphic: true

      t.integer :last_edited_by
      t.timestamps
    end

    add_index :messages, [:messageable_type, :messageable_id]
  end
end
