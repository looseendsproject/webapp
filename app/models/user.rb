# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
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
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  ROLES = %w[user manager admin].freeze

  include LooseEndsSearchable

  search_query_includes :projects, :finisher
  search_text_fields :first_name, :last_name, :email
  search_sort_name_field :last_name
  search_default_sort "name asc"

  class HeardAboutUs
    HEARD_ABOUT_US_OPTIONS = {
      'Facebook' => {  additional: false },
      'Instagram' => {  additional: false },
      'Newspaper' => {  additional: true },
      'Radio' => {  additional: true },
      'TV' => {  additional: true },
      'AARP Magazine' => {  additional: false },
      'Other Magazine' => {  additional: true },
      'Friend' => {  additional: false },
      'Local Yarn Store' => {  additional: false },
      'Saw a Flyer' => {  additional: false },
      'Other' => {  additional: true }
    }.freeze

    def self.options_for_select
      HEARD_ABOUT_US_OPTIONS.keys
    end

    def self.options_for_additional
      results = []
      HEARD_ABOUT_US_OPTIONS.map { |k,v| results << k if v[:additional] }
      results
    end
  end

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
  validates :heard_about_us, presence: true

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
    @results = @results.where(users: { role: params[:role] }) if params[:role].present?
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

  # For use in mailer previews so as to not expose any personal info
  def self.fake
    new({
      first_name: "Fake",
      last_name: "User",
      email: "fake_user@example.com"
    })
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
