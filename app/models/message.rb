# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id               :bigint           not null, primary key
#  channel          :string
#  click_count      :integer          default(0), not null
#  description      :string
#  expires_at       :datetime
#  last_edited_by   :integer
#  messageable_type :string
#  redirect_to      :string
#  sgid             :string
#  single_use       :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  messageable_id   :bigint
#
# Indexes
#
#  index_messages_on_channel                              (channel)
#  index_messages_on_messageable                          (messageable_type,messageable_id)
#  index_messages_on_messageable_type_and_messageable_id  (messageable_type,messageable_id)
#  index_messages_on_sgid                                 (sgid)
#
class Message < ApplicationRecord
  class SGIDExistsError < StandardError; end

  DEFAULT_MAGIC_LINK_DURATION = 7.days

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
    Mail.from_source Mail::Encodings::QuotedPrintable.decode(content.to_plain_text)
  end
  alias_method :mail, :email

  def path_to_messageable
    "/manage/#{messageable.class.to_s.pluralize.downcase}/#{messageable.id}"
  end

  # set_sgid! (bare) uses default duration and default redirect_to, not single use
  # expires_at takes precedence over expires_in
  #
  def set_sgid!(expires_in: DEFAULT_MAGIC_LINK_DURATION, single_use: false,
      redirect_to: nil, expires_at: nil)

    raise SGIDExistsError if sgid.present? # don't overwrite an existing sgid

    if expires_at.present? # takes precedence
      sgid = self.to_sgid(expires_at: expires_at)
    else
      sgid = self.to_sgid(expires_in: expires_in)
    end

    self.expires_at = sgid.expires_at
    self.sgid = sgid.to_s
    self.single_use = single_use
    self.redirect_to = redirect_to
    save!
  end

  # SGIDs are only valid on outbound w/ sgid and can expire or get used up (if single_use)
  def valid_sgid?
    return true unless channel == 'outbound' && sgid.present?
    return false if single_use && click_count > 0
    return false if expires_at&.past? # nil does not expire
    true
  end

  def expired?
    expires_at&.past? # nil does not expire
  end

  # Sends replacement email with fresh sgid
  #
  # NOTE: Probably don't need this.  If anyone with the link can
  # self-reissue a new one, it's functionally the same as a
  # never-expiring link.
  #
  def send_replacement!
    klass, action = mailer.split(".")
    klass.constantize.with(resource: messageable).send(action).deliver_now
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

    return unless assignment.project.status.match(/^in process/i)

    # HACK Temporarily disable update.  Need to make the logic smarter
    # assignment.update_attribute(:last_contacted_at, Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end
end
