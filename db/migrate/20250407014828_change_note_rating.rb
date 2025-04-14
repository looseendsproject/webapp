class ChangeNoteRating < ActiveRecord::Migration[8.0]
  def change
    remove_column :notes, :rating
    add_column :notes, :headline, :string
  end
end
