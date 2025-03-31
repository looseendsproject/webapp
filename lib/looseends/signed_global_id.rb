# frozen_string_literal: true

module Looseends
  class SignedGlobalID < SignedGlobalID

    class << self

      # By encoding both allowed path and message_id
      # in the sgid, we can check request params against
      # those values to safely reissue and expired sgid.
      #
      # Unescaped format: "/finisher/new|5"
      # CGI.escapeURIComponent format: "%2Ffinisher%2Fnew%7C5"
      #
      # On successful locate, controller redirects to path.
      #
      def encode_purpose(path:, mailer:)
        CGI.escapeURIComponent("#{path}|#{mailer}")
      end

      # [path, message_id]
      def decode_purpose(purpose)
        purpose.split("|")
      end

      def get_resend_action(sgid)
        # return href ready for "Resend" button
        "flurp"
      end
    end

    attr_accessor :sgid, :purpose

    def initialize(options = {})
      super
      @sgid = options[:sgid]
      @path = pick_path(options)
      @message_id = options[:message_id]
      @mailer = pick_mailer(options)
    end

    def expired?
    end

    def valid_for_reissue?
    end

    private

      def pick_mailer(options)
        [path, message_id] = self.class.decode_purpose(@purpose)

      end

      def pick_path(options)
      end

  end
end
