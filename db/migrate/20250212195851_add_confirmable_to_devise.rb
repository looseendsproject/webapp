class AddConfirmableToDevise < ActiveRecord::Migration[7.0]

  # see https://github.com/heartcombo/devise/wiki/How-To:-Add-:confirmable-to-Users

  def up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_index :users, :confirmation_token, unique: true
  end

  def down
    remove_index :users, :confirmation_token
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end
end
