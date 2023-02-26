class Project < ApplicationRecord

  STATUSES = ['proposed', 'approved', 'in progress', 'finished']

  belongs_to :user
  has_many :assignments
  has_many :volunteers, through: :assignments

  has_many_attached :crafter_images
  has_many_attached :project_images
  has_many_attached :pattern_files
  has_many_attached :material_images

  before_validation :set_default_status


  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }

  validates :description, presence: true
  validates :status, presence: true
  validates :street, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :postal_code, presence: true
  validates :craft_type, presence: true
  validates :has_pattern, presence: true
  validates :material_type, presence: true
  validates :crafter_name, presence: true
  validates :crafter_description, presence: true


  validates :terms_of_use, acceptance: true

  validates :project_images, attached: true, content_type: [:png, :jpg, :jpeg, :webp, :gif]
  validates :crafter_images, attached: false, content_type: [:png, :jpg, :jpeg, :webp, :gif]
  validates :material_images, attached: false, content_type: [:png, :jpg, :jpeg, :webp, :gif]

  def set_default_status
    self.status ||= 'proposed'
  end

  def volunteer
    volunteers.first
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

  def append_crafter_images=(attachables)
    crafter_images.attach(attachables)
  end

  def append_project_images=(attachables)
    project_images.attach(attachables)
  end

  def append_pattern_files=(attachables)
    pattern_files.attach(attachables)
  end

  def append_material_images=(attachables)
    material_images.attach(attachables)
  end

end
