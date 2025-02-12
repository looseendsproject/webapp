# frozen_string_literal: true

class Assignment < ApplicationRecord
  belongs_to :project
  belongs_to :finisher
  belongs_to :user

  has_many :assignment_updates, dependent: :destroy

  validates :finisher_id, uniqueness: { scope: :project_id }

  def self.active
    where(ended_at: nil)
  end
end
