# frozen_string_literal: true

# == Schema Information
#
# Table name: notes
#
#  id           :bigint           not null, primary key
#  notable_type :string
#  sentiment    :string
#  text         :text
#  visibility   :string           default("manager"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  notable_id   :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_notes_on_notable  (notable_type,notable_id)
#  index_notes_on_user_id  (user_id)
#
class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true, touch: true
  belongs_to :user

  before_create :set_visibility

  private

    def set_visibility
      case notable.class.to_s
      when "Project"
        self.visibility = "manager"
      when "Assignment"
        self.visibility = "finisher"
      else
        raise NotImplementedError
      end
    end
end
