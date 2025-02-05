class User < ApplicationRecord
  ROLES = ['user', 'manager', 'admin']
  HEARD_ABOUT_US_OPTIONS = [
    'Facebook', 'Instagram', 'Newspaper', 'Radio', 'TV', 'AARP Magazine',
    'Other Magazine', 'Friend', 'Local Yarn Store', 'Saw a Flyer', 'Other'
  ].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  validates :role, inclusion: { in: ROLES }
  before_validation :set_default_role

  has_many :projects, dependent: :destroy
  has_one :finisher, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :heard_about_us, presence: true

  def set_default_role
    if (User.count < 3)
      self.role = 'admin'
    end
    self.role ||= 'user'
  end

  def self.search(params)
    @results = self.includes(:projects, :finisher)
    if params[:search].present?
      @results = @results.where("users.first_name iLike :name OR users.last_name iLike :name OR users.email iLike :name", { name: "#{params[:search]}%" })
    end
    if params[:role].present?
      @results = @results.where("users.role = :role", { role: params[:role] })
    end
    if params[:sort].present?
      if params[:sort] == 'name'
        @results = @results.order(:last_name)
      else
        @results = @results.order(:created_at)
      end
    else
      @results = @results.order(:last_name)
    end
    return @results
  end


  def name
    "#{first_name} #{last_name}"
  end

  def self.project_managers
    where(role: %w[admin manager], is_project_manager: true)
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

  def finisher?
    !!finisher
  end

end
