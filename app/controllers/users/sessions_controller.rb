# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :ensure_params, only: [:magic_link]

    # Sign in user and redirect
    # GET /magic_link?sgid=eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaEpJaDVuYVdRNkx5OXN...
    #
    def magic_link
      attempt_locate || handle_not_located
    end

    private

      def ensure_params
        begin
          params.require(:sgid)
        rescue ActionController::ParameterMissing
          redirect_to '/users/sign_in', flash: { error: "Bad link. Please sign in to proceed." }
          return
        end
      end

      # If the action needs to do anything before redirect
      #
      def attempt_locate(&block)
        message = GlobalID::Locator.locate_signed(params[:sgid])
        if message.present? && message.user.is_a?(User)
          message.increment!(:click_count)
          sign_in(message.user)

          yield if block_given?

          redirect_to message.send_link_action! and return true
        end
      end

      # Locator returned nil. Figure out if it's expired or malformed
      #
      def handle_not_located
        message = Message.find_by(sgid: params[:sgid])

        if message.present? && message.expired?
          render
        else
          raise ActiveRecord::RecordNotFound
        end
      end

  end
end
