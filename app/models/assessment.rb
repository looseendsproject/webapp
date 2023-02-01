class Assessment < ApplicationRecord
  belongs_to :skill
  belongs_to :volunteer

  validates :skill, uniqueness: { scope: :volunteer }
end
