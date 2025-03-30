class AddChannelToMessage < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :channel, :string
    add_index :messages, :channel
  end
end
