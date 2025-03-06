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
#  has_workplace_match            :boolean
#  in_home_pets                   :string
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
#  index_finishers_on_joined_on  (joined_on)
#  index_finishers_on_latitude   (latitude)
#  index_finishers_on_longitude  (longitude)
#  index_finishers_on_user_id    (user_id)
#
class Finisher < ApplicationRecord
  belongs_to :user
  validates :user, uniqueness: true

  has_one_attached :picture

  has_many_attached :finished_projects

  has_many :active_assignments, lambda { where(status: ['invited', 'accepted', 'unresponsive'])}, class_name: 'Assignment'

  has_many :assignments, dependent: :destroy
  has_many :projects, through: :assignments

  has_many :assessments, dependent: :destroy
  has_many :rated_assessments, lambda {
    includes(:skill).where(rating: 1..).order("skills.position, skills.name")
  }, class_name: "Assessment"
  has_many :skills, -> { order("skills.position, skills.name") }, through: :assessments

  has_many :favorites, dependent: :destroy
  has_many :products, through: :favorites

  accepts_nested_attributes_for :assessments

  validates :chosen_name, presence: true
  validates :phone_number, length: { minimum: 10, too_short: "is too short.  It must be at least %<count>s digits." }

  validates :terms_of_use, acceptance: true
  validates :finished_projects, content_type: %i[png jpg jpeg webp gif],
                                size: { greater_than_or_equal_to: 5.kilobytes }
  validates :picture, content_type: %i[png jpg jpeg webp gif], size: { greater_than_or_equal_to: 5.kilobytes }

  serialize :in_home_pets, Array

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

  def self.get_sql(search_string)
    attributes = ["users.first_name", "users.last_name", "users.email", "finishers.state", "finishers.city",
                  "finishers.chosen_name"]
    description = "finishers.description"
    keywords = search_string.strip.split(/\s+/)
    conditions = []
    match_strings = []
    keywords.each do |keyword|
      phrase = []
      attributes.each do |attr|
        phrase << "#{attr} iLIKE ?"
        match_strings << "%#{keyword}%"
      end
      conditions << ("(#{phrase.join(" OR ")})")
    end
    str = conditions.join(" AND ") + " OR #{description} ~* ?"
    match_strings << "\\y#{search_string}\\y"
    [str, match_strings].flatten
  end

  def self.search(params)
    @results = joins(:user)
    if params[:search].present?
      @results = if params[:search].match(/^[0-9]+$/)
                   @results.where("finishers.postal_code iLIKE :zip", { zip: "#{params[:search]}%" })
                 else
                   @results.where(get_sql(params[:search]))
                 end
    end
    if params[:since].present?
      since_date = Date.parse(params[:since])
      @results = @results.where(joined_on: since_date..)
    end
    if params[:product_id].present?
      @results = @results.joins(:favorites).where(favorites: { product_id: params[:product_id] })
    end
    if params[:available].present?
      if params[:available] == "yes"
        @results = @results.where.not(unavailable: true)
      elsif params[:available] == "no"
        @results = @results.where(unavailable: true)
      end
    end
    if params[:skill_id].present?
      @results = @results.joins(:assessments).where(assessments: { skill_id: params[:skill_id], rating: 1.. })
    end
    @results = @results.where(state: params[:state]) if params[:state].present?
    @results = if params[:sort].present?
                 case params[:sort]
                 when "name asc"
                   @results.order("LOWER(finishers.chosen_name) ASC")
                 when "name desc"
                   @results.order("LOWER(finishers.chosen_name) DESC")
                 when "date asc"
                   @results.order(joined_on: :asc)
                 when "date desc"
                   @results.order(joined_on: :desc)
                 else
                   @results.order(:joined_on)
                 end
               else
                 @results.order(:joined_on)
               end
    @results = @results.where(country: params[:country]) if params[:country].present?
    if params[:has_workplace_match].present? && params[:has_workplace_match] == "1"
      @results = @results.where(has_workplace_match: true)
    end
    @results
  end

  def missing_address_information?
    street.blank? ||
      city.blank? ||
      state.blank? ||
      country.blank? ||
      postal_code.blank?
  end

  def missing_assessments?
    assessments.all? { |a| (a[:rating]).zero? }
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
    self.active_assignments.size > 0
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

  def send_welcome_message
    FinisherMailer.welcome(self).deliver_now
  end

  def send_profile_complete_message
    FinisherMailer.profile_complete(self).deliver_now
  end

  # method for combining all available address attributes for geocoding
  def full_address
    [street, street_2, city, state, postal_code, country].compact.join(", ")
  end

  # method for checking if any address attribute has changed
  def full_address_has_changed?
    street_changed? || street_2_changed? || city_changed? || state_changed? || postal_code_changed? || country_changed?
  end
end
