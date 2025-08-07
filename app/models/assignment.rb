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

  # Policy decided values
  DEFAULT_CHECK_IN_INTERVAL = 3 # weeks
  UNRESPONSIVE_AFTER = 9 # weeks

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

  # Determines which assignments COULD get check-ins right now.  There
  # is another check in SendCheckInsJob that determines whether the
  # Finisher is unresponsive.
  def self.needs_check_in
    # Get superset of stale assignments based on default interval
    stale_assignment_ids = active.joins(:project).where("
      assignments.status = ?
      AND projects.status = ?
      AND (last_contacted_at < ? OR last_contacted_at IS NULL)
      AND (check_in_sent_at < ? OR check_in_sent_at IS NULL)
      AND projects.name NOT LIKE '%[IMPORT]%'
      ",
      STATUSES[:accepted], Project::STATUSES[:in_process_underway],
        DEFAULT_CHECK_IN_INTERVAL.weeks.ago, DEFAULT_CHECK_IN_INTERVAL.weeks.ago).pluck(:id)

    # Finishers with custom intervals
    custom_finisher_ids = Finisher.where.not(check_in_interval: nil).pluck(:id)

    # Assignments with custom intervals through Finisher
    custom_assignment_ids = Assignment.where(finisher_id: custom_finisher_ids).pluck(:id)

    # Remove custom assignments from superset
    initial_ids = stale_assignment_ids - custom_assignment_ids

    # Check each custom assignment to see if it should be added into the final set
    final_ids = initial_ids
    custom_assignment_ids.each do |custom_id|
      next unless stale_assignment_ids.include?(custom_id) # only consider matches from superset
      custom_assignment = Assignment.find(custom_id)

      # Include if they've never gotten a check-in or if last_contacted_at is older then
      # that Finisher's custom interval
      final_ids << custom_id if should_include_assignment?(custom_assignment)
    end

    # The collection of Assignments that need check in now
    return Assignment.where(id: final_ids)
  end

  # Used in self.needs_check_in.  For readability
  def self.should_include_assignment?(custom_assignment)
    return true if custom_assignment.last_contacted_at.blank?

    check_in_after = custom_assignment.last_contacted_at +
      custom_assignment.finisher.check_in_interval.weeks
    return true if Time.zone.now > check_in_after

    false
  end

  def check_in_interval
    finisher.check_in_interval || DEFAULT_CHECK_IN_INTERVAL
  end

  def missed_check_ins?
    (status == STATUSES[:accepted] &&
      project.status == Project::STATUSES[:in_process_underway] &&
      (last_contacted_at.present? && last_contacted_at < UNRESPONSIVE_AFTER.weeks.ago)) ? true : false
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
