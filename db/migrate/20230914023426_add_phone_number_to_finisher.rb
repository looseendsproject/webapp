class AddPhoneNumberToFinisher < ActiveRecord::Migration[7.0]
  def change
    add_column :finishers, :phone_number, :string
    add_column :projects, :phone_number, :string
    User.all.each do |user|
      if user.finisher?
        user.finisher.update_column(:phone_number, user.phone)
      end
      user.projects.each do |project|
        project.update_column(:phone_number, user.phone)
      end
    end
  end
end
