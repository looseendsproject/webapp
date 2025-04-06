class AddUserIdToNote < ActiveRecord::Migration[8.0]
  def change
    add_reference :notes, :user
  end
end
