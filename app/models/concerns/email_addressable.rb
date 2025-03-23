# frozen_string_literal: true

require "active_support/concern"

# Assigns unique email addresses to records for inbound parse
module EmailAddressable
  extend ActiveSupport::Concern

  LENGTH = 8
  DESTINATION_HOST = ENV['INBOUND_MAIL_HOST'] || 'localhost'

  included do |base|
    before_validation :ensure_inbound_email_address
    validates :inbound_email_address, uniqueness: true
  end

  def ensure_inbound_email_address
    self.inbound_email_address ||= unique_address
  end

  private

  def unique_address
    loop do
      str = SecureRandom.alphanumeric LENGTH
      uniq = "#{self.class.to_s}-#{str}@" + DESTINATION_HOST
      return uniq unless self.class.where(inbound_email_address: uniq).exists?
    end
  end
end
