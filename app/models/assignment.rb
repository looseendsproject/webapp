class Assignment < ApplicationRecord
  belongs_to :project
  belongs_to :volunteer
  belongs_to :user

  has_many :assignment_updates

  def self.active
    self.where(ended_at: nil)
  end

end
