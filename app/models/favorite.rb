class Favorite < ApplicationRecord
  belongs_to :product
  belongs_to :finisher

  validates :product, uniqueness: { scope: :finisher }
end
