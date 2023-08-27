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


  validates :status, inclusion: { in: STATUSES }
  validates :status, presence: true

  validates :name, presence: true
  validates :description, presence: true
  validates :craft_type, presence: true
  validates :terms_of_use, acceptance: true

  validates :project_images, attached: false, content_type: [:png, :jpg, :jpeg, :webp, :gif]
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

  def self.has_status (status_state)
    where({ status: status_state })
  end

  def self.has_assigned (assigned_state)
    if (assigned_state === 'true')
      joins(:assignments).where({ assignments: { ended_at: nil } })
    elsif (assigned_state === 'false')
      joins(:assignments).where.not({ assignments: { ended_at: nil } })
    end
  end


  def missing_information?
    description.blank? || missing_address_information?
  end

  def missing_address_information?
    street.blank? ||
    city.blank? ||
    state.blank? ||
    country.blank? ||
    postal_code.blank?
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
