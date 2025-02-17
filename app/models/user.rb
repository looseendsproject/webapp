# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string           default(""), not null
#  heard_about_us         :text
#  is_project_manager     :boolean
#  last_name              :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  phone                  :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("user"), not null
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  ROLES = %w[user manager admin].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  validates :role, inclusion: { in: ROLES }
  before_validation :set_default_role

  has_many :projects, dependent: :destroy
  has_one :finisher, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  def set_default_role
    self.role = "admin" if User.count < 3
    self.role ||= "user"
  end

  def self.search(params)
    @results = includes(:projects, :finisher)
    if params[:search].present?
      @results = @results.where(
        "users.first_name iLike :name OR users.last_name iLike :name OR users.email iLike :name", { name: "#{params[:search]}%" }
      )
    end
    @results = @results.where("users.role = :role", { role: params[:role] }) if params[:role].present?
    @results = if params[:sort].present?
                 if params[:sort] == "name"
                   @results.order(:last_name)
                 else
                   @results.order(:created_at)
                 end
               else
                 @results.order(:last_name)
               end
    @results
  end

  def name
    "#{first_name} #{last_name}"
  end

  def self.project_managers
    where(role: %w[admin manager], is_project_manager: true)
  end

  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def can_manage?
    admin? || manager?
  end

  def finisher?
    !!finisher
  end
end
