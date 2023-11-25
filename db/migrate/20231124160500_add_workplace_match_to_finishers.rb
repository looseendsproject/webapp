class AddWorkplaceMatchToFinishers < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :workplace_name, :string
    add_column :finishers, :has_workplace_match, :boolean
  end
end
