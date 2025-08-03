# frozen_string_literal: true

# == Schema Information
#
# Table name: finishers
#
#  id                             :bigint           not null, primary key
#  admin_notes                    :text
#  approved_at                    :datetime
#  can_publicize                  :boolean
#  chosen_name                    :string
#  city                           :string
#  country                        :string
#  description                    :text             not null
#  dislikes                       :text
#  dominant_hand                  :string
#  emergency_contact_email        :string
#  emergency_contact_name         :string
#  emergency_contact_phone_number :string
#  emergency_contact_relation     :string
#  has_completed_profile          :boolean          default(FALSE)
#  has_smoke_in_home              :boolean          default(FALSE)
#  has_taken_ownership_of_profile :boolean          default(FALSE)
#  has_volunteer_time_off         :boolean
#  has_workplace_match            :boolean
#  in_home_pets                   :string
#  inbound_email_address          :string
#  joined_on                      :date
#  latitude                       :float
#  longitude                      :float
#  no_cats                        :boolean
#  no_dogs                        :boolean
#  no_smoke                       :boolean
#  other_favorites                :text
#  other_skills                   :text
#  phone_number                   :string
#  postal_code                    :string
#  pronouns                       :string
#  social_media                   :text
#  state                          :string
#  street                         :string
#  street_2                       :string
#  terms_of_use                   :boolean
#  unavailable                    :boolean          default(FALSE)
#  workplace_name                 :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  user_id                        :bigint           not null
#
# Indexes
#
#  index_finishers_on_inbound_email_address  (inbound_email_address) UNIQUE
#  index_finishers_on_joined_on              (joined_on)
#  index_finishers_on_latitude               (latitude)
#  index_finishers_on_longitude              (longitude)
#  index_finishers_on_user_id                (user_id)
#
class Finisher < ApplicationRecord
  include LooseEndsSearchable
  include EmailAddressable

  search_query_joins :user
  search_text_fields :"finishers.description", :"finishers.chosen_name", :"finishers.city", :"finishers.state",
                     :"users.first_name", :"users.last_name", :"users.email", :"finishers.other_skills"
  search_since_field :joined_on
  search_sort_name_field :chosen_name
  search_default_sort "name asc"

  belongs_to :user
  validates :user, uniqueness: true

  has_one_attached :picture

  has_many_attached :finished_projects

  has_many :active_assignments, lambda {
    where(status: %w[invited accepted unresponsive])
  }, class_name: "Assignment"

  has_many :assignments, dependent: :destroy
  has_many :projects, through: :assignments

  has_many :assessments, dependent: :destroy
  has_many :rated_assessments, lambda {
    includes(:skill).where(rating: 1..).order("skills.position, skills.name")
  }, class_name: "Assessment"
  has_many :skills, -> { order("skills.position, skills.name") }, through: :assessments

  has_many :favorites, dependent: :destroy
  has_many :products, through: :favorites
  has_many :messages, as: :messageable

  accepts_nested_attributes_for :assessments

  validates :chosen_name, presence: true
  validates :phone_number, length:
    { minimum: 10, too_short: "is too short.  It must be at least %<count>s digits." },
                           allow_blank: true

  validates :terms_of_use, acceptance: true
  validates :finished_projects, content_type: %i[png jpg jpeg webp gif heic],
                                size: { greater_than_or_equal_to: 5.kilobytes },
                                limit: { max: 5 },
                                if: ->(obj) { obj.attachment_changes['finished_projects'].present? }
  validates :picture, content_type: %i[png jpg jpeg webp gif heic], size: { greater_than_or_equal_to: 5.kilobytes }

  serialize :in_home_pets

  before_create do
    self.joined_on = Time.zone.today if joined_on.blank?
  end

  after_validation :geocode, if: ->(obj) { obj.full_address.present? and obj.full_address_has_changed? }
  after_create :send_welcome_message, if: proc { has_taken_ownership_of_profile }
  after_save :see_if_finisher_has_completed_profile, if: proc { has_taken_ownership_of_profile }

  geocoded_by :full_address

  def see_if_finisher_has_completed_profile
    return if has_completed_profile
    return if missing_information?

    update_column(:has_completed_profile, true)
    send_profile_complete_message
  end

  def rated_skills_string
    rated_assessments.map { |assessment| "#{assessment.skill.name} (#{assessment.rating})" }.join(", ")
  end

  def approved?
    approved_at != nil
  end

  def approved
    approved?
  end

  def missing_information?
    description.blank? || dominant_hand.blank? || missing_address_information? || missing_assessments? || missing_favorites?
  end

  # For use in mailer previews
  def self.fake
    new({ user: User.fake })
  end

  def missing_address_information?
    street.blank? ||
      city.blank? ||
      state.blank? ||
      country.blank? ||
      postal_code.blank?
  end

  def missing_assessments?
    assessments.all? { |a| a[:rating].zero? }
  end

  def missing_favorites?
    favorites.empty?
  end

  def approved=(val)
    self.approved_at = (DateTime.now if val == "1")
  end

  def self.approved
    where.not({ approved_at: nil })
  end

  def assigned?
    active_assignments.size > 0
  end

  def name
    user.name == chosen_name ? chosen_name : "#{chosen_name} (#{user.name})"
  end

  def assigned_to(project)
    assignments.exists?(project_id: project.id)
  end

  def append_finished_projects=(attachables)
    finished_projects.attach(attachables)
  end

  def confirm_email=(value)
    user.update_attribute(:confirmed_at, Time.zone.now) if value == "1"
  end

  def send_welcome_message
    FinisherMailer.with(resource: self).welcome.deliver_now
  end

  def send_profile_complete_message
    FinisherMailer.with(resource: self).profile_complete.deliver_now
  end

  # method for combining all available address attributes for geocoding
  def full_address
    [street, street_2, city, state, postal_code, country].compact_blank.join(", ")
  end

  # method for checking if any address attribute has changed
  def full_address_has_changed?
    street_changed? || street_2_changed? || city_changed? || state_changed? || postal_code_changed? || country_changed?
  end
end
