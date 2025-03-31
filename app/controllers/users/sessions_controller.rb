# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # GET /magic_link?sgid=LONGSGID&purpose=<url encoded purpose string>
    def magic_link
      begin
        params.require([:sgid, :purpose])
      rescue ActionController::ParameterMissing
        redirect_to '/users/sign_in', flash: { error: "Bad link. Please sign in to proceed." }
        return
      end

      sgid = Looseends::SignedGlobalID.new(params)

      message = GlobalID::Locator.locate_signed(params[:sgid], for: sgid.purpose)
      if message.present? && message.user.is_a?(User)
        sign_in(user)
        redirect_to params[:path] and return
      end

      begin
        SignedGlobalID.verifier.verify(params[:sgid], purpose: params[:purpose])
      rescue ActiveSupport::MessageVerifier::InvalidSignature => e
        error = e.to_s
      end

      if error == "expired"
        @error = "Link expired.  Send new link below."
        @resend_action = Looseends::SignedGlobalID.get_resend_action(params[:sgid])
        render
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    # POST /magic_link?path=some/path&sgid=LONGSGID
    def resend_link
      # mailer action
    end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
    #
  end
end
