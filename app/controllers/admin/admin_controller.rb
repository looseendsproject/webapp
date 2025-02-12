# frozen_string_literal: true

module Admin
  class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    layout "admin"

    def require_admin
      return if current_user.admin?

      redirect_to root_path
    end
  end
end
