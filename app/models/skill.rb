class Skill < ApplicationRecord
  POPULAR_SKILLS = %w[Knit Crochet Quilting]

  has_many :assessments, dependent: :destroy
  has_many :finishers, -> { where assessments: { rating: 1.. } }, through: :assessments

  validates :name, presence: true

  def self.[](val)
    { 0 => :no_experience, 1 => :beginner, 2 => :intermediate, 3 => :expert }[val]
  end

  def self.sorted_by_popularity
    where(name: POPULAR_SKILLS).order(:name) + where.not(name: POPULAR_SKILLS).order(:name)
  end
end
