# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                        :bigint           not null, primary key
#  can_publicize             :boolean
#  can_share_crafter_details :boolean          default(FALSE)
#  can_use_first_name        :boolean          default(FALSE)
#  city                      :string
#  country                   :string
#  craft_type                :string
#  crafter_description       :text
#  crafter_dominant_hand     :string
#  crafter_name              :string
#  description               :text
#  group_project             :boolean          default(FALSE)
#  has_pattern               :string
#  has_smoke_in_home         :boolean          default(FALSE)
#  in_home_pets              :string
#  in_process_status         :string
#  influencer                :boolean          default(FALSE)
#  joann_helped              :boolean          default(FALSE)
#  latitude                  :float
#  longitude                 :float
#  material_type             :string
#  more_details              :text
#  name                      :string           not null
#  no_cats                   :boolean
#  no_dogs                   :boolean
#  no_smoke                  :boolean
#  phone_number              :string
#  postal_code               :string
#  press                     :boolean          default(FALSE)
#  press_outlet              :string
#  press_region              :string
#  privacy_needed            :boolean          default(FALSE)
#  ready_status              :string
#  recipient_name            :string
#  state                     :string
#  status                    :string           default("drafted"), not null
#  street                    :string
#  street_2                  :string
#  terms_of_use              :boolean
#  urgent                    :boolean          default(FALSE)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  group_manager_id          :bigint
#  manager_id                :bigint
#  user_id                   :bigint
#
# Indexes
#
#  index_projects_on_group_manager_id  (group_manager_id)
#  index_projects_on_latitude          (latitude)
#  index_projects_on_longitude         (longitude)
#  index_projects_on_manager_id        (manager_id)
#  index_projects_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_manager_id => finishers.id)
#  fk_rails_...  (manager_id => users.id)
#
class Project < ApplicationRecord
  STATUSES = [
    "drafted",
    "proposed",
    "submitted via google",
    "project confirm email sent",
    "ready to match",
    "finisher invited",
    "project accepted/waiting on terms",
    "introduced",
    "in process",
    "finished/not returned",
    "done",
    "unresponsive",
    "on hold",
    "will not do",
    "waiting for return to rematch",
    "weird circumstance"
  ].freeze

  READY_TO_MATCH_STATUSES = [
    "new",
    "new - additional attempt",
    "new - needs to go on facebook",
    "old - needs match with a second skill",
    "old - finisher requested rematch"
  ].freeze

  IN_PROCESS_STATUSES = [
    "connected (both finisher and po have responded)",
    "po still has project",
    "humming along",
    "check in",
    "po out of touch"
  ].freeze

  belongs_to :manager, optional: true, class_name: "User"
  belongs_to :user, optional: true
  belongs_to :group_manager, class_name: "Finisher", optional: true
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
  validates :phone_number, length: { minimum: 10, too_short: "is too short.  It must be at least %<count>s digits." }
  validates :description, presence: true
  validates :craft_type, presence: true
  validates :terms_of_use, acceptance: true

  validates :project_images, attached: true, content_type: %i[png jpg jpeg webp gif],
                             size: { greater_than_or_equal_to: 5.kilobytes }
  validates :crafter_images, attached: false, content_type: %i[png jpg jpeg webp gif],
                             size: { greater_than_or_equal_to: 5.kilobytes }
  validates :material_images, attached: false, content_type: %i[png jpg jpeg webp gif],
                              size: { greater_than_or_equal_to: 5.kilobytes }

  validates :group_manager, presence: true, if: :group_project?
  validates :press_region, presence: true, if: :press?
  validates :press_outlet, presence: true, if: :press?

  serialize :in_home_pets, Array
  geocoded_by :full_address
  after_validation :geocode, if: lambda { |obj|
    obj.full_address.present? && obj.full_address_has_changed?
  }

  before_save :clear_ready_status_unless_ready_to_match
  before_save :clear_in_process_status_unless_in_process

  after_update :move_to_proposed

  def move_to_proposed
    return unless !missing_information? && status == "drafted"

    update_column(:status, "proposed")
  end

  def set_default_status
    self.status ||= "drafted"
  end

  def finisher
    finishers.first
  end

  def self.proposed
    where({ status: "proposed" })
  end

  def self.submitted_via_google
    where({ status: "submitted via google" })
  end

  def self.project_confirm_email_sent
    where({ status: "project confirm email sent" })
  end

  def self.ready_to_match
    where({ status: "ready to match" })
  end

  def self.finisher_invited
    where({ status: "finisher invited" })
  end

  def self.project_accepted_waiting_on_terms
    where({ status: "project accepted/waiting on terms" })
  end

  def self.introduced
    where({ status: "introduced" })
  end

  def self.in_process
    where({ status: "in process" })
  end

  def self.finished
    where({ status: "finished/not returned" })
  end

  def self.done
    where({ status: "done" })
  end

  def self.unresponsive
    where({ status: "unresponsive" })
  end

  def self.on_hold
    where({ status: "on hold" })
  end

  def self.will_not_do
    where({ status: "will not do" })
  end

  def self.waiting_for_return_to_rematch
    where({ status: "waiting for return to rematch" })
  end

  def self.weird_circumstance
    where({ status: "weird circumstance" })
  end

  def self.has_status(status_state)
    where({ status: status_state })
  end

  def self.has_ready_status(status)
    where(ready_status: status)
  end

  def self.has_in_process_status(status)
    where(in_process_status: status)
  end

  def self.has_assigned(assigned_state)
    if assigned_state === "true"
      joins(:assignments).distinct
    elsif assigned_state === "false"
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
    street_changed? || street_2_changed? || city_changed? || state_changed? || postal_code_changed? || country_changed?
  end

  private

  def clear_ready_status_unless_ready_to_match
    self.ready_status = nil unless status == "ready to match"
  end

  def clear_in_process_status_unless_in_process
    self.in_process_status = nil unless status == "in process"
  end
end
