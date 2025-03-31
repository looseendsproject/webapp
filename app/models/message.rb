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

  validates_presence_of :messageable
  validates :channel, inclusion: { in: %w(inbound outbound),
      message: "%{value} is not a valid message channel" }

  before_validation :set_defaults
  after_create :update_last_contacted_at

  def self.since(since)
    where(created_at: (since..Time.now)).order(created_at: :desc)
  end

  def self.inbound
    where(channel: 'inbound')
  end

  def self.outbound
    where(channel: 'outbound')
  end

  def user
    return messageable if self.messageable.is_a?(User)
    self.messageable.user
  end

  def email
    Mail.from_source content.to_plain_text
  end

  def path_to_messageable
    "/manage/#{messageable.class.to_s.pluralize.downcase}/#{messageable.id}"
  end

  private

  # Messageable must respond to #name
  def set_defaults
    self.channel ||= 'inbound'
    self.description ||= "#{messageable.class.to_s.downcase}/#{messageable.name}"
  end

  def update_last_contacted_at
    return unless messageable_type == "Project" && channel == "inbound"

    # TODO: Find assignment by specific email user. For now use active assignment
    assignment = messageable.active_assignment
    return unless assignment

    assignment.update_attribute(:last_contacted_at, Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end
end
