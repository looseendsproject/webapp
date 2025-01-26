class AddEmergencyContactToFinisher < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :emergency_contact_name, :string
    add_column :finishers, :emergency_contact_phone_number, :string
    add_column :finishers, :emergency_contact_email, :string
    add_column :finishers, :emergency_contact_relation, :string
  end
end
