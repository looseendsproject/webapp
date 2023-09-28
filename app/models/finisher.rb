class Finisher < ApplicationRecord
  belongs_to :user
  validates :user, uniqueness: true

  has_one_attached :picture

  has_many_attached :finished_projects

  has_many :assignments, dependent: :destroy
  has_many :projects, through: :assignments

  has_many :assessments, dependent: :destroy
  has_many :skills, through: :assessments
  has_many :rated_assessments, -> { where(:rating => 1..)}, :class_name => 'Assessment'

  has_many :favorites, dependent: :destroy
  has_many :products, through: :favorites

  accepts_nested_attributes_for :assessments

  validates :chosen_name, presence: true
  validates :phone_number, presence: true
  validates :terms_of_use, acceptance: true
  validates :finished_projects, content_type: [:png, :jpg, :jpeg, :webp, :gif]

  before_create do
    self.joined_on = Date.today if self.joined_on.blank?
  end

  after_create :send_welcome_message, if: Proc.new { self.has_taken_ownership_of_profile }
  after_save :see_if_finisher_has_completed_profile, if: Proc.new { self.has_taken_ownership_of_profile }

  def see_if_finisher_has_completed_profile
    if (!has_completed_profile)
      if !missing_information?
        update_column(:has_completed_profile, true)
        send_profile_complete_message
      end
    end
  end

  def approved?
    self.approved_at != nil
  end

  def approved
    approved?
  end

  def missing_information?
    description.blank? || dominant_hand.blank? || missing_address_information? || missing_assessments? || missing_favorites?
  end

  def self.search(params)
    @results = self.all.includes(:products, :skills).with_attached_picture.joins(:user)
    if params[:search].present?

      if params[:search].match(/^[0-9]+$/)
        @results = @results.where("finishers.postal_code iLIKE :zip", { zip: "#{params[:search]}%" })
      else
        @results = @results.where("users.first_name iLike :name OR users.last_name iLike :name OR users.email iLike :name OR finishers.chosen_name iLIKE :name OR finishers.description ~* :desc", { name: "#{params[:search]}%", desc: "\\y#{params[:search]}\\y" })
      end
    end
    if params[:product_id].present?
      @results = @results.joins(:favorites).where(:favorites => { product_id: params[:product_id]})
    end
    if params[:available].present?
      if params[:available] == 'yes'
        @results = @results.where.not(unavailable: true)
      elsif params[:available] == 'no'
        @results = @results.where(unavailable: true)
      end
    end
    if params[:skill_id].present?
      @results = @results.joins(:assessments).where(:assessments => { skill_id: params[:skill_id], rating: 1.. })
    end
    if params[:state].present?
      @results = @results.where(:state => params[:state])
    end
    if params[:sort].present?
      if params[:sort] == 'name'
        @results = @results.order(:chosen_name)
      else
        @results = @results.order(:joined_on)
      end
    else
      @results = @results.order(:joined_on)
    end
    if params[:country].present?
      @results = @results.where(:country => params[:country])
    end
    return @results
  end

  def missing_address_information?
    street.blank? ||
    city.blank? ||
    state.blank? ||
    country.blank? ||
    postal_code.blank?
  end

  def missing_assessments?
    assessments.all? { |a| a[:rating] == 0 }
  end

  def missing_favorites?
    favorites.length == 0
  end

  def approved=(val)
    if val == '1'
      self.approved_at = DateTime.now
    else
      self.approved_at = nil
    end
  end

  def self.approved
    self.where.not({ approved_at: nil })
  end

  def name
    user.name != chosen_name ? "#{chosen_name} (#{user.name})" : chosen_name
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
  
  # logic for geocoding a finisher
  geocoded_by :full_address
  after_validation :geocode, if: :address_attribute_has_changed?
  
  # method for combining all available address attributes for geocoding
  def full_address
    [street, street_2, city, state, postal_code, country].compact.join(", ") 
  end

  # method for checking if any address attribute has changed
  def address_attribute_has_changed? 
    street_changed?||street_2_changed?||city_changed?||state_changed?||postal_code_changed?||country_changed?
  end 

end


