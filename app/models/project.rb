class Project < ApplicationRecord

  STATUSES = ['proposed', 'approved', 'in progress', 'finished']
  validates :name, presence: true

  belongs_to :user
  has_many :assignments
  has_many :volunteers, through: :assignments

  has_many_attached :crafter_images
  has_many_attached :project_images
  has_many_attached :pattern_images
  has_many_attached :material_images

  before_validation :set_default_status

  validates :status, inclusion: { in: STATUSES }

  validates :terms_of_use, :acceptance => true

  def set_default_status
    self.status ||= 'proposed'
  end

  def self.proposed
    where({ status: 'proposed' })
  end

  def self.approved
    where({ status: 'approved' })
  end

  def self.in_progress
    where({ status: 'in progress' })
  end

  def self.finished
    where({ status: 'finished' })
  end

end
