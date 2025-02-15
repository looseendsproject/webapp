# frozen_string_literal: true

# == Schema Information
#
# Table name: project_notes
#
#  id          :bigint           not null, primary key
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_project_notes_on_project_id  (project_id)
#  index_project_notes_on_user_id     (user_id)
#
class ProjectNote < ApplicationRecord
  belongs_to :project, touch: true
  belongs_to :user
end
