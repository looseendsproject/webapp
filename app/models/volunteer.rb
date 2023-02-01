class Volunteer < ApplicationRecord
  belongs_to :user

  has_one_attached :picture

  has_many :assignments
  has_many :projects, through: :assignments

  has_many :assessments
  has_many :skills, through: :assessments

  accepts_nested_attributes_for :assessments

  def approved?
    self.approved_at != nil
  end

  def approved
    approved?
  end

  def approved=(val)
    if (val == '1')
      self.approved_at = DateTime.now
    else
      self.approved_at = nil
    end
  end

  def name
    user.name
  end

end
