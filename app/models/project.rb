class Project < ApplicationRecord
  validates :name, presence: true

  belongs_to :user
  has_many :assignments
  has_many :volunteers, through: :assignments

  has_many_attached :crafter_images
  has_many_attached :project_images
  has_many_attached :pattern_images
  has_many_attached :material_images

  before_validation :set_default_status

  def set_default_status
    self.status ||= 'new'
  end

end
