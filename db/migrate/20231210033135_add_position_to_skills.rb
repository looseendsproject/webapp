class AddPositionToSkills < ActiveRecord::Migration[7.0]
  POPULAR_SKILLS = %w[Knit Crochet Quilting]
  def up
    add_column :skills, :position, :integer
    skills = Skill.where(name: POPULAR_SKILLS).order(:name) + Skill.where.not(name: POPULAR_SKILLS).order(:name)
    skills.each_with_index do |skill, index|
      skill.update_columns(position: index)
    end
  end
  def down
    remove_column :skills, :position
  end
end
