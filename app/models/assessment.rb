class Assessment < ApplicationRecord
  belongs_to :skill
  belongs_to :volunteer

  validates :skill, uniqueness: { scope: :volunteer }

  validates :rating, numericality: { min: 1, max: 3 }
end
