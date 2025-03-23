class AddLastContactedAtToAssignment < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :last_contacted_at, :datetime
  end
end
