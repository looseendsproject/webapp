# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id                :bigint           not null, primary key
#  created_by        :bigint
#  ended_at          :datetime
#  last_contacted_at :datetime
#  started_at        :datetime
#  status            :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  finisher_id       :bigint
#  project_id        :bigint
#
# Indexes
#
#  index_assignments_on_created_by   (created_by)
#  index_assignments_on_finisher_id  (finisher_id)
#  index_assignments_on_project_id   (project_id)
#
class Assignment < ApplicationRecord
  STATUS = %w[potential invited accepted declined unresponsive completed].freeze
  CHECK_IN_INTERVAL = 2.weeks

  belongs_to :project, touch: true
  belongs_to :finisher
  belongs_to :creator, class_name: "User", foreign_key: :created_by

  has_many :notes, as: :notable
  has_many :messages, as: :messageable

  validates :finisher_id, uniqueness: { scope: :project_id }
  validates :status, inclusion: { in: STATUS, allow_blank: true }

  before_save :sanitize_status
  after_save :denormalize_created_by

  def self.active
    where(ended_at: nil)
  end

  def self.needs_check_in
    active.where("status = ? AND last_contacted_at < ?",
      "accepted", Time.zone.now.beginning_of_day - CHECK_IN_INTERVAL)
  end

  def name
    project.description
  end

  # Messageable must respond to "user".  In this context,
  # "user" is "finisher.user"...
  def user
    finisher.user
  end

  private

  def sanitize_status
    self.status = nil if status.blank?
  end

  def denormalize_created_by
    self.project.update!(manager_id: created_by) \
      unless self.project.manager_id.present?
  end
end
