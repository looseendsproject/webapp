class CreateProjectViews < ActiveRecord::Migration[8.0]
  def change
    create_table :project_views do |t|
      t.bigint :user_id, null: false
      t.text :name, null: false
      t.jsonb :query, null: false, default: {}

      t.timestamps
    end
  end
end
