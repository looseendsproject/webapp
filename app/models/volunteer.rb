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
  validates :country, presence: true
  validates :postal_code, presence: true
  validates :assessments, presence: true

  after_save :trim_assessments

  def trim_assessments
    assessments.where(rating: 0).destroy_all
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

  def append_finished_images=(attachables)
    finished_images.attach(attachables)
  end

  def all_assessments
    all_assessments = self.assessments
    Skill.all.each do |skill|
      if all_assessments.where(skill_id: skill.id).none?
        all_assessments << Assessment.new( {skill_id: skill.id, rating: 0} )
      end
    end
    all_assessments
  end

end
