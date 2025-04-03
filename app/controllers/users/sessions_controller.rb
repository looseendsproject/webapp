# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController

    # GET /magic_link?sgid=eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaEpJaDVuYVdRNkx5OXN...
    def magic_link
      begin
        params.require(:sgid)
      rescue ActionController::ParameterMissing
        redirect_to '/users/sign_in', flash: { error: "Bad link. Please sign in to proceed." }
        return
      end

      # Happy path.  Message found.  all good
      #
      message = GlobalID::Locator.locate_signed(params[:sgid])
      if message.present? && message.user.is_a?(User)
        message.increment!(:click_count)
        sign_in(message.user)
        redirect_to message.send_link_action! and return
      end

      # Locator returned nil. Figure out if it's expired or malformed
      #
      message = Message.find_by(sgid: params[:sgid])

      if message.present? && message.expired?
        @replacement = message.send_replacement!
        render
      else
        raise ActiveRecord::RecordNotFound
      end
    end

  end
end
