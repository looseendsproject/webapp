class AddNeedsAttention < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :needs_attention, :string
  end
end
