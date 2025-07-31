# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id                :bigint           not null, primary key
#  check_in_sent_at  :datetime
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
  STATUSES = {
    potential: "potential",
    invited: "invited",
    accepted: "accepted",
    declined: "declined",
    requested_rematch: "requested rematch",
    unresponsive: "unresponsive",
    completed: "completed"
  }.freeze

  CHECK_IN_INTERVAL = 2.weeks
  UNRESPONSIVE_INTERVAL = 8.weeks
  MISSED_CHECK_INS = 4

  belongs_to :project, touch: true
  belongs_to :finisher
  belongs_to :creator, class_name: "User", foreign_key: :created_by

  has_many :notes, as: :notable
  has_many :messages, as: :messageable

  validates :finisher_id, uniqueness: { scope: :project_id }
  validates :status, inclusion: { in: STATUSES.values, allow_blank: true }

  before_save :sanitize_status
  after_save :denormalize_created_by

  def self.active
    where(ended_at: nil)
  end

  def self.needs_check_in
    active.joins(:project).where("
      assignments.status = ?
      AND projects.status = ?
      AND (last_contacted_at < ? OR last_contacted_at IS NULL)
      AND (check_in_sent_at < ? OR check_in_sent_at IS NULL)
      AND projects.name NOT LIKE '%[IMPORT]%'
      ",
      STATUSES[:accepted], Project::STATUSES[:in_process_underway],
        CHECK_IN_INTERVAL.ago, CHECK_IN_INTERVAL.ago)
  end

  def missed_check_ins?
    (status == STATUSES[:accepted] &&
      project.status == Project::STATUSES[:in_process_underway] &&
      (last_contacted_at.present? && last_contacted_at < UNRESPONSIVE_INTERVAL.ago)) ? true : false
  end

  def name
    project.name
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
