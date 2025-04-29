class AddHeadersToMessage < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :email_headers, :jsonb, null: false, default: {}
  end
end
