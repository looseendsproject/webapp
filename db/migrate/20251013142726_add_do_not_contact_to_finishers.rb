class AddDoNotContactToFinishers < ActiveRecord::Migration[8.0]
  def change
    add_column :finishers, :do_not_contact, :boolean, default: false, null: false
  end
end
