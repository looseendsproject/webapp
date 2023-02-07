class Skill < ApplicationRecord
  has_many :assessments
  has_many :volunteers, through: :assessments



  def self.[](val)
    { 0 => :no_experience, 1 => :beginner, 2 => :intermediate, 3 => :expert }[val]
  end
end
