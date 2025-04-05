class ExtendMessageForSgiDs < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :sgid, :string # 255 char.  might need :text
    add_column :messages, :link_action, :string
    add_column :messages, :click_count, :integer, null: false, default: 0
    add_column :messages, :single_use, :boolean, null: false, default: false
    add_column :messages, :mailer, :string
    add_column :messages, :expires_at, :datetime


    add_index :messages, :sgid
  end
end
