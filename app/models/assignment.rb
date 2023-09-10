class Assignment < ApplicationRecord
  belongs_to :project
  belongs_to :finisher
  belongs_to :user

  has_many :assignment_updates, dependent: :destroy

  def self.active
    self.where(ended_at: nil)
  end

end
