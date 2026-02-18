# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # Let magic_link run even when already signed in so we can show "already been used"
    # instead of Devise's "You are already signed in." redirect to root.
    skip_before_action :require_no_authentication, only: [:magic_link]
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
          redirect_to '/users/sign_in', flash: { alert: "Bad link. Please contact support." }
          return
        end
      end

      # Pass a block if the action needs to do anything before redirect
      #
      def attempt_locate(&block)
        message = GlobalID::Locator.locate_signed(params[:sgid])
        if message.present? && message.user.is_a?(User)
          unless message.valid_sgid?
            # If the user is already signed in, show the "already used" message
            # on a page they are allowed to visit (not the sign-in page, which
            # Devise will immediately redirect away from with "You are already signed in.")
            if user_signed_in?
              redirect_to "/", flash: { alert: "This link has already been used." }
            else
              redirect_to "/users/sign_in", flash: { alert: "This link has already been used." }
            end
            return true
          end
          message.increment!(:click_count)

          sign_in(message.user)

          # If they follow any magic link, confirm the email
          #
          message.user.update_attribute(:confirmed_at, Time.zone.now) \
            unless message.user.confirmed?

          yield if block_given?

          redirect_to(message.redirect_to || "/")
          return true
        end
        false
      end

      # Locator returned nil. Figure out if it's expired or malformed
      #
      def handle_not_located
        message = Message.find_by(sgid: params[:sgid])

        if message.present? && message.expired?
          redirect_to "/users/sign_in", flash: { alert: "Expired link. Please contact support." }
          return true
        else
          raise ActiveRecord::RecordNotFound
        end
      end

  end
end
