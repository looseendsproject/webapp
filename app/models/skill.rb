# frozen_string_literal: true

# == Schema Information
#
# Table name: skills
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Skill < ApplicationRecord
  has_many :assessments, dependent: :destroy
  has_many :finishers, -> { where assessments: { rating: 1.. } }, through: :assessments

  validates :name, presence: true

  def self.[](val)
    { 0 => :no_experience, 1 => :beginner, 2 => :intermediate, 3 => :expert }[val]
  end

  def self.sorted_by_popularity
    order(:position, :name)
  end
end
