# frozen_string_literal: true

module Looseends
  class SignedGlobalID < SignedGlobalID

    class << self

      # By encoding both allowed path and mailer action
      # in the sgid, we can check request params against
      # those values to safely reissue and expired sgid.
      #
      # Format: "/finisher/new|FinisherMailer.welcome"
      #
      # On successful locate, controller redirects to path.
      #
      def encode_purpose(path:, mailer:)
        "#{path}|#{mailer}"
      end

      def decode_purpose(purpose)
        purpose.split("|")
      end
    end

    def initialize(sgid)
      super
      # parse
    end

  end
end
