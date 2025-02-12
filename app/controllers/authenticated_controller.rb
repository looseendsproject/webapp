# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :require_current_user

  def require_current_user
    return if current_user

    redirect_to root_path
  end
end
