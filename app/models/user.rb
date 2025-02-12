# frozen_string_literal: true

class User < ApplicationRecord
  ROLES = %w[user manager admin].freeze

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
