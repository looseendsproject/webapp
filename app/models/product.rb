class Product < ApplicationRecord
  has_many :favorites
  has_many :finishers, through: :favorites
end
