class Project < ApplicationRecord

  STATUSES = [
    'draft', 'proposed', 'breakup/decline', 'on hold', 'project confirmation email sent/ready to match',
    'finisher invited', 'rematch', 'project accepted', 'introduced', 'humming along', 'unresponsive',
    'f2f rematch', 'done'
  ]

  belongs_to :manager, optional: true, class_name: 'User'
  belongs_to :user, optional: true
  has_many :assignments, dependent: :destroy
  has_many :finishers, through: :assignments
  has_many :project_notes, dependent: :destroy

  has_many_attached :crafter_images
  has_many_attached :project_images
  has_many_attached :pattern_files
  has_many_attached :material_images

  before_validation :set_default_status

  validates :status, inclusion: { in: STATUSES }
  validates :status, presence: true

  validates :name, presence: true
  validates :phone_number, length: { minimum: 10, too_short: "is too short.  It must be at least %{count} digits." }
  validates :description, presence: true
  validates :craft_type, presence: true
  validates :terms_of_use, acceptance: true

  validates :project_images, attached: true, content_type: [:png, :jpg, :jpeg, :webp, :gif]
  validates :crafter_images, attached: false, content_type: [:png, :jpg, :jpeg, :webp, :gif]
  validates :material_images, attached: false, content_type: [:png, :jpg, :jpeg, :webp, :gif]

  serialize :in_home_pets, Array
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj){
    puts obj.full_address
    puts obj.full_address_has_changed?
    obj.full_address.present? && obj.full_address_has_changed?
  }

  after_update :move_to_proposed

  def move_to_proposed
    if !missing_information? && status == 'draft'
      update_column(:status, 'proposed')
    end
  end

  def set_default_status
    self.status ||= 'draft'
  end

  def finisher
    finishers.first
  end

  def self.proposed
    where({ status: 'proposed' })
  end

  def self.breakup_decline
    where({ status: 'breakup/decline' })
  end

  def self.on_hold
    where({ status: 'on hold' })
  end

  def self.project_confirmation_email_sent_ready_to_match
    where({ status: 'project confirmation email sent/ready to match' })
  end

  def self.finisher_invited
    where({ status: 'finisher invited' })
  end

  def self.rematch
    where({ status: 'rematch' })
  end

  def self.project_accepted
    where({ status: 'project accepted' })
  end

  def self.introduced
    where({ status: 'introduced' })
  end

  def self.humming_along
    where({ status: 'humming along' })
  end

  def self.unresponsive
    where({ status: 'unresponsive' })
  end

  def self.f2f_rematch
    where({ status: 'f2f rematch' })
  end

  def self.done
    where({ status: 'done' })
  end

  def self.has_status (status_state)
    where({ status: status_state })
  end

  def self.has_assigned (assigned_state)
    if (assigned_state === 'true')
      joins(:assignments).distinct
    elsif (assigned_state === 'false')
      where.missing(:assignments)
    end
  end

  def missing_information?
    description.blank? || phone_number.blank? || missing_address_information? || has_pattern.blank? || material_type.blank? || project_images.blank?
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

  # method for combining all available address attributes for geocoding
  def full_address
    [street, street_2, city, state, postal_code, country].compact.join(", ")
  end

  # method for checking if any address attribute has changed
  def full_address_has_changed?
    street_changed?||street_2_changed?||city_changed?||state_changed?||postal_code_changed?||country_changed?
  end

end
