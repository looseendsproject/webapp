# frozen_string_literal: true

class Assessment < ApplicationRecord
  belongs_to :skill
  belongs_to :finisher

  validates :skill, uniqueness: { scope: :finisher }

  validates :rating, numericality: { min: 1, max: 3 }
end
