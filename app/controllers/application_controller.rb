# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def test_flash_messages
    flash.alert = "Careful here! (:alert)"
    flash.notice = "Nice work! (:notice)"
    redirect_to new_user_session_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  def after_sign_up_path_for(resource_or_scope)
    raise
    stored_location_for(resource_or_scope) || root_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location = stored_location_for(resource_or_scope)
    return stored_location if stored_location.present?
    return manage_dashboard_path if resource&.can_manage?

    root_path
  end

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
