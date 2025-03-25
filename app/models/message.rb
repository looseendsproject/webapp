# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  channel          :string
#  description      :string
#  last_edited_by   :integer
#  messageable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  messageable_id   :bigint
#
# Indexes
#
#  index_messages_on_channel                              (channel)
#  index_messages_on_messageable                          (messageable_type,messageable_id)
#  index_messages_on_messageable_type_and_messageable_id  (messageable_type,messageable_id)
#
class Message < ApplicationRecord
  belongs_to :messageable, polymorphic: true
  has_rich_text :content

  validates :channel, inclusion: { in: %w(inbound outbound),
      message: "%{value} is not a valid message channel" }

  before_validation :set_defaults

  def self.since(since)
    where(created_at: (since..Time.now)).order(created_at: :desc)
  end

  def self.inbound
    where(channel: 'inbound')
  end

  def self.outbound
    where(channel: 'outbound')
  end

  def email
    Mail.from_source content.to_plain_text
  end

  private

  def set_defaults
    self.channel ||= 'inbound'
  end
end
