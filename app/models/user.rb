class User < ApplicationRecord
  enum role: %i[user manager admin]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :role, inclusion: { in: roles.keys }
  before_validation :set_default_role

  has_many :projects

  def set_default_role
    self.role = 'user'
  end

end
