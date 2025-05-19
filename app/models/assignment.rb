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
    working: "working",
    declined: "declined",
    requested_rematch: "requested rematch",
    unresponsive: "unresponsive",
    completed: "completed"
  }.freeze

  CHECK_IN_INTERVAL = 2.weeks
  UNRESPONSIVE_INTERVAL = 8.weeks
  MISSED_CHECK_INS = 4
  ACTIVE_STATUSES = STATUSES.values_at(:accepted, :working).freeze

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
    active.joins(:project)
          .where(status: ACTIVE_STATUSES)
          .where(project: { status: Project::STATUSES[:in_process_underway] })
          .where("last_contacted_at < ? OR last_contacted_at IS NULL", CHECK_IN_INTERVAL.ago)
          .where("check_in_sent_at < ? OR check_in_sent_at IS NULL", CHECK_IN_INTERVAL.ago)
  end

  def missed_check_ins?
    return false unless ACTIVE_STATUSES.include?(status) &&
                        project.status == Project::STATUSES[:in_process_underway] &&
                        last_contacted_at < UNRESPONSIVE_INTERVAL.ago

    check_ins = notes.order(created_at: :desc).limit(MISSED_CHECK_INS)
    return false unless check_ins.count == MISSED_CHECK_INS

    true
  end

  delegate :name, to: :project

  # Messageable must respond to "user".  In this context,
  # "user" is "finisher.user"...
  delegate :user, to: :finisher

  private

  def sanitize_status
    self.status = nil if status.blank?
  end

  def denormalize_created_by
    project.update!(manager_id: created_by) \
      unless project.manager_id.present?
  end
end
