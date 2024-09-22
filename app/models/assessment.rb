class Assessment < ApplicationRecord
  belongs_to :skill
  belongs_to :finisher

  validates :skill, uniqueness: { scope: :finisher }

  validates :rating, numericality: { min: 1, max: 3 }

  validates :can_work_without_pattern, numericality: { min: 1, max: 3 }

  def to_s
    "#{self.skill.name}: #{Skill[self.rating].to_s.humanize}. #{self.no_pattern_string} #{self.description}"
  end

  private
  def no_pattern_string
    if !self.can_work_without_pattern || self.can_work_without_pattern == 0
      ""
    else
      verb = { 1 => :cannot, 2 => :can_maybe, 3 => :can }[self.can_work_without_pattern]
      "#{verb.to_s.humanize} work without pattern."
    end
  end
end
