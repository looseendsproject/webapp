class RenameJoannHelped < ActiveRecord::Migration[8.0]
  def change
    rename_column :projects, :joann_helped, :company_helped
    add_column :projects, :help_company, :text
  end
end
