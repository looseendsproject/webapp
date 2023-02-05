class Product < ApplicationRecord
  has_many :favorites
  has_many :volunteers, through: :favorites
end
