class User < ApplicationRecord
  ROLES = ['user', 'manager', 'admin']

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  validates :role, inclusion: { in: ROLES }
  before_validation :set_default_role

  has_many :projects, dependent: :destroy
  has_one :volunteer, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  def set_default_role
    if (User.count < 3)
      self.role = 'admin'
    end
    self.role ||= 'user'
  end

  def name
    "#{first_name} #{last_name}"
  end

  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager'
  end

  def can_manage?
    admin? || manager?
  end

  def volunteer?
    !!volunteer
  end

end
