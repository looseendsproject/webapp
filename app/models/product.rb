class Product < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :finishers, through: :favorites

  validates :name, presence: true
end
