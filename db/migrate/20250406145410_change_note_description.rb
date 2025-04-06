class ChangeNoteDescription < ActiveRecord::Migration[8.0]
  def change
    rename_column :notes, :description, :text
  end
end
