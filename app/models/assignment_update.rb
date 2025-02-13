# frozen_string_literal: true

# == Schema Information
#
# Table name: assignment_updates
#
#  id            :bigint           not null, primary key
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_assignment_updates_on_assignment_id  (assignment_id)
#  index_assignment_updates_on_user_id        (user_id)
#
class AssignmentUpdate < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
end
