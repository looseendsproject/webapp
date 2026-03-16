# frozen_string_literal: true

class AddOkToPostToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :ok_to_post, :boolean, default: false, null: false
  end
end

