class RenameNoteHeadline < ActiveRecord::Migration[8.0]
  def change
    rename_column :notes, :headline, :sentiment
  end
end
