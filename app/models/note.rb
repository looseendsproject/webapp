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

  SENTIMENTS = {
    "going_well" => {
      textarea_label: "Great! Tell us more if you'd like",
      require_text: false,
      alert_manager: false,
      table_class: "table-success"
    },
    "not_going_great" => {
      textarea_label: "Sorry to hear that. Tell us more and your \
        Project Manager will contact you.",
      require_text: true,
      alert_manager: true,
      table_class: "table-danger"
    },
    "no_progress" => {
      textarea_label: "OK. We will check back later. Leave a note if you'd like.",
      require_text: false,
      alert_manager: true,
      table_class: "table-warning"
    }
  }

  belongs_to :notable, polymorphic: true, touch: true
  belongs_to :user

  before_create :set_visibility
  after_create :flag_project

  private

    # Set project.needs_attention = true for negative sentiments
    #
    def flag_project
      # TODO
    end

    # TODO probably don't need this b/c visibility
    # is determined by notable_type
    #
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
