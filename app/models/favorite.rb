class Favorite < ApplicationRecord
  belongs_to :product
  belongs_to :volunteer

  validates :product, uniqueness: { scope: :volunteer }
end
