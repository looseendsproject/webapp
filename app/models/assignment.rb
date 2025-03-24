# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id                :bigint           not null, primary key
#  ended_at          :datetime
#  last_contacted_at :datetime
#  started_at        :datetime
#  status            :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  finisher_id       :bigint
#  project_id        :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_assignments_on_finisher_id  (finisher_id)
#  index_assignments_on_project_id   (project_id)
#  index_assignments_on_user_id      (user_id)
#
class Assignment < ApplicationRecord
  STATUS = %w[potential invited accepted declined unresponsive completed].freeze

  belongs_to :project, touch: true
  belongs_to :finisher
  belongs_to :user

  has_many :assignment_updates, dependent: :destroy

  validates :finisher_id, uniqueness: { scope: :project_id }
  validates :status, inclusion: { in: STATUS, allow_blank: true }

  before_save :sanitize_status

  def self.active
    where(ended_at: nil)
  end

  private

  def sanitize_status
    self.status = nil if status.blank?
  end
end
