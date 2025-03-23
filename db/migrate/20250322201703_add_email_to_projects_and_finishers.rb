class AddEmailToProjectsAndFinishers < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :inbound_email_address, :string
    add_column :finishers, :inbound_email_address, :string

    add_index :projects, :inbound_email_address, unique: true
    add_index :finishers, :inbound_email_address, unique: true
  end
end
