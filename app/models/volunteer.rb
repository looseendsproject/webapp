class Volunteer < ApplicationRecord
  belongs_to :user
  validates :user, uniqueness: true

  has_one_attached :picture

  has_many_attached :finished_projects

  has_many :assignments
  has_many :projects, through: :assignments

  has_many :assessments
  has_many :skills, through: :assessments

  has_many :favorites
  has_many :products, through: :favorites

  accepts_nested_attributes_for :assessments

  validates :name, presence: true
  validates :description, presence: true
  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :country, presence: true
  validates :postal_code, presence: true
  validate :has_a_skill
  validates :dominant_hand, presence: true

  validates :terms_of_use, acceptance: true


  validates :finished_projects, content_type: [:png, :jpg, :jpeg, :webp, :gif]


  def has_a_skill
    if assessments.all? { |a| a[:rating] == 0 }
      errors.add(:assessments, "are required")
    end
  end

  def approved?
    self.approved_at != nil
  end

  def approved
    approved?
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
