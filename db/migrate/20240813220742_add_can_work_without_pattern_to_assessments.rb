class AddCanWorkWithoutPatternToAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :can_work_without_pattern, :integer
  end
end
