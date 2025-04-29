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
      classification: "positive",
      alert_manager: false
    },
    "need_help" => {
      classification: "negative",
      alert_manager: true
    },
    "no_progress" => {
      classification: "neutral",
      alert_manager: false
    }
  }

  belongs_to :notable, polymorphic: true, touch: true
  belongs_to :user

  before_create :set_visibility
  after_create :flag_project

  scope :for_assignment, -> { where(notable_type: 'Assignment') }

  def negative?
    return false unless sentiment.present? && SENTIMENTS[sentiment].present?
    SENTIMENTS[sentiment][:classification] == "negative"
  end

  private

    # Set project.needs_attention = true for negative sentiments
    #
    def flag_project
      # if notable is Assignment and sentiment is alert, set project.needs_attention
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
