class RefactorMessage < ActiveRecord::Migration[8.0]
  def change
    remove_column(:messages, :mailer)
    rename_column(:messages, :link_action, :redirect_to)
  end
end
