class Volunteer < ApplicationRecord
  belongs_to :user
  validates :user, uniqueness: true

  has_one_attached :picture

  has_many_attached :finished_projects

  has_many :assignments, dependent: :destroy
  has_many :projects, through: :assignments

  has_many :assessments, dependent: :destroy
  has_many :skills, through: :assessments

  has_many :favorites, dependent: :destroy
  has_many :products, through: :favorites

  accepts_nested_attributes_for :assessments

  validates :chosen_name, presence: true
  validates :terms_of_use, acceptance: true
  validates :finished_projects, content_type: [:png, :jpg, :jpeg, :webp, :gif]

  before_create do
    self.joined_on = Date.today if self.joined_on.blank?
  end

  def approved?
    self.approved_at != nil
  end

  def approved
    approved?
  end

  def missing_information?
    description.blank? || dominant_hand.blank? || missing_address_information? || missing_assessments?
  end

  def self.search(params)
    @results = self.all.includes(:products, :skills).with_attached_picture.joins(:user)
    if params[:search].present?

      if params[:search].match(/\d+/)
        @results = @results.where("volunteers.postal_code iLIKE :zip", { zip: "#{params[:search]}%" })
      else
        @results = @results.where("users.first_name iLike :name OR users.last_name iLike :name OR users.email iLike :name OR volunteers.chosen_name iLIKE :name OR volunteers.description ~* :desc", { name: "#{params[:search]}%", desc: "\\y#{params[:search]}\\y" })
      end
    end
    if params[:product_id].present?
      @results = @results.joins(:favorites).where(:favorites => { product_id: params[:product_id]})
    end
    if params[:skill_id].present?
      @results = @results.joins(:assessments).where(:assessments => { skill_id: params[:skill_id]})
    end
    if params[:state].present?
      @results = @results.where(:state => params[:state])
    end
    if params[:sort].present?
      if params[:sort] == 'date'
        @results = @results.order(:joined_on)
      else
        @results = @results.order(:chosen_name)
      end
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
    user.name
  end

  def append_finished_projects=(attachables)
    finished_projects.attach(attachables)
  end

end
