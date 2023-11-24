class AddWorkplaceMatchToFinishers < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :workplace, :string
    add_column :finishers, :workplace_match, :boolean
  end
end
