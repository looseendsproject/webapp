# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  def after_sign_up_path_for(resource_or_scope)
    raise
    stored_location_for(resource_or_scope) || root_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
