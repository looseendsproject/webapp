class Assignment < ApplicationRecord
  STATUS = %w[potential invited accepted declined unresponsive completed].freeze

  belongs_to :project
  belongs_to :finisher
  belongs_to :user

  has_many :assignment_updates, dependent: :destroy

  validates :finisher_id, uniqueness: { scope: :project_id }
  validates :status, inclusion: { in: STATUS }, allow_nil: true

  def self.active
    where(ended_at: nil)
  end
end
