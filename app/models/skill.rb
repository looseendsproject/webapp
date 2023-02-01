class Skill < ApplicationRecord
  has_many :assessments
  has_many :volunteers, through: :talents
end
