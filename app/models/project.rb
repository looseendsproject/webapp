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
#  has_materials             :string
#  has_pattern               :string
#  has_smoke_in_home         :boolean          default(FALSE)
#  in_home_pets              :string
#  in_process_status         :string
#  inbound_email_address     :string
#  influencer                :boolean          default(FALSE)
#  joann_helped              :boolean          default(FALSE)
#  latitude                  :float
#  longitude                 :float
#  material_brand            :text
#  material_type             :string
#  more_details              :text
#  name                      :string           not null
#  needs_attention           :string
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
#  status                    :string           default("PROPOSED"), not null
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
#  index_projects_on_group_manager_id       (group_manager_id)
#  index_projects_on_inbound_email_address  (inbound_email_address) UNIQUE
#  index_projects_on_latitude               (latitude)
#  index_projects_on_longitude              (longitude)
#  index_projects_on_manager_id             (manager_id)
#  index_projects_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_manager_id => finishers.id)
#  fk_rails_...  (manager_id => users.id)
#
class Project < ApplicationRecord
  STATUSES = {
    proposed: "PROPOSED",
    waiting_for_project_confirmation: "WAITING PROJECT CONFIRMATION",
    ready_to_match_new: "READY TO MATCH: NEW",
    ready_to_match_additional_attempt: "READY TO MATCH: ADDITIONAL ATTEMPT",
    ready_to_match_needs_second_skill: "READY TO MATCH: NEEDS SECOND SKILL",
    ready_to_match_rematch_requested: "READY TO MATCH: REMATCH REQUESTED",
    finisher_invited: "FINISHER INVITED",
    accepted_waiting_terms: "ACCEPTED WAITING TERMS",
    introduced: "INTRODUCED",
    in_process_connected: "IN PROCESS: CONNECTED",
    in_process_waiting_handoff: "IN PROCESS: WAITING HANDOFF",
    in_process_underway: "IN PROCESS: UNDERWAY",
    in_process_po_unresponsive: "IN PROCESS: PO UNRESPONSIVE",
    finished_not_returned: "FINISHED NOT RETURNED",
    done: "DONE",
    on_hold: "ON HOLD",
    will_not_do: "WILL NOT DO",
    test: "TEST"
  }.freeze

  BOOLEAN_ATTRIBUTES = %i[joann_helped urgent influencer group_project press privacy_needed].freeze

  NEEDS_ATTENTION_REASONS = %w(negative_sentiment stalled_accepted
    stalled_invited stalled_potential long_running)

  include LooseEndsSearchable
  include EmailAddressable

  search_query_joins :user
  search_sort_name_field :name
  search_text_fields :"projects.name", :"projects.description", :"projects.craft_type", :"projects.material_type",
                     :"projects.material_brand", :"projects.city", :"projects.state", :"users.first_name",
                     :"users.last_name", :"users.email"
  search_default_sort "date desc"

  belongs_to :manager, optional: true, class_name: "User"
  belongs_to :user, optional: true
  belongs_to :group_manager, class_name: "Finisher", optional: true
  has_many :assignments, dependent: :destroy
  has_many :finishers, through: :assignments
  has_many :messages, as: :messageable
  has_many :notes, as: :notable

  has_many_attached :crafter_images
  has_many_attached :project_images
  has_many_attached :pattern_files
  has_many_attached :material_images

  before_validation :set_default_status

  validates :status, inclusion: { in: STATUSES.values }
  validates :status, presence: true
  validates :needs_attention, inclusion: {
    in: NEEDS_ATTENTION_REASONS, allow_blank: true, allow_nil: true }

  validates :name, presence: true
  validates :phone_number, length: { minimum: 10, too_short: "is too short.  It must be at least %<count>s digits." }
  validates :description, presence: true
  validates :craft_type, presence: true
  validates :terms_of_use, acceptance: true

  validates :project_images, attached: true, content_type: %i[png jpg jpeg webp gif],
                             size: { greater_than_or_equal_to: 5.kilobytes }
  validates :crafter_images, attached: false, content_type: %i[png jpg jpeg webp gif],
                             size: { greater_than_or_equal_to: 5.kilobytes }
  validates :material_images, presence: true, if: :has_materials?
  validates :material_images, attached: false, content_type: %i[png jpg jpeg webp gif],
                              size: { greater_than_or_equal_to: 5.kilobytes }
  validates :pattern_files, presence: true, if: :has_pattern?

  validates :group_manager, presence: true, if: :group_project?
  validates :press_region, presence: true, if: :press?
  validates :press_outlet, presence: true, if: :press?

  serialize :in_home_pets
  geocoded_by :full_address
  after_validation :geocode, if: lambda { |obj|
    obj.full_address.present? && obj.full_address_has_changed?
  }

  scope :ignore_tests, -> { where.not(status: "test") }
  scope :needing_attention, -> { where.not(needs_attention: [nil, ""]).order(name: :asc) }

  def set_default_status
    self.status ||= "PROPOSED"
  end

  def finisher
    finishers.first
  end

  def finisher_name
    finisher&.name
  end

  def owner_email
    user&.email
  end

  def owner_phone
    user&.phone
  end

  def active_assignment
    assignments.find_by(status: "accepted")
  end

  def active_finisher
    active_assignment&.finisher
  end

  def self.has_assigned(assigned_state)
    if assigned_state === "true"
      joins(:assignments).distinct
    elsif assigned_state === "false"
      where.missing(:assignments)
    end
  end

  # Helper for options_for_select
  #
  def self.needs_attention_options
    opts = []
    NEEDS_ATTENTION_REASONS.map do |nar|
      opts << [nar.titleize, nar]
    end
    opts
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

  def has_pattern?
    has_pattern == 'Yes'
  end

  def has_materials?
    has_materials == 'Yes'
  end
end
