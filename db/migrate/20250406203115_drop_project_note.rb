class DropProjectNote < ActiveRecord::Migration[8.0]
  def change

    # Don't accidentally drop the table until data is moved
    if Note.count > 0
      drop_table :project_notes, if_exists: true
    end
  end
end
