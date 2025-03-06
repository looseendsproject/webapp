# frozen_string_literal: true

# == Schema Information
#
# Table name: assessments
#
#  id          :bigint           not null, primary key
#  description :text
#  rating      :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  finisher_id :bigint
#  skill_id    :bigint
#
# Indexes
#
#  index_assessments_on_finisher_id  (finisher_id)
#  index_assessments_on_skill_id     (skill_id)
#
class Assessment < ApplicationRecord
  belongs_to :skill
  belongs_to :finisher

  validates :skill, uniqueness: { scope: :finisher }

  # 1 == Beginner
  # 2 == Intermediate
  # 3 == Expert
  validates :rating, numericality: { min: 1, max: 3 }
end
