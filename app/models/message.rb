# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  description      :string
#  last_edited_by   :integer
#  messageable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  messageable_id   :bigint
#
# Indexes
#
#  index_messages_on_messageable                          (messageable_type,messageable_id)
#  index_messages_on_messageable_type_and_messageable_id  (messageable_type,messageable_id)
#
class Message < ApplicationRecord
  belongs_to :messageable, polymorphic: true
  has_rich_text :content

  after_create :update_last_contacted_at

  def email
    Mail.from_source content.to_plain_text
  end

  private

  def update_last_contacted_at
    return unless messageable_type == "Project"

    # TODO: Find assignment by specific email user. For now use active assignment
    assignment = messageable.active_assignment
    return unless assignment

    assignment.update_attribute(:last_contacted_at, Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end
end
