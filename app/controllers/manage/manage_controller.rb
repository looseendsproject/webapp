# frozen_string_literal: true

module Manage
  class ManageController < ApplicationController
    before_action :authenticate_user!
    before_action :require_manager

    layout "manage"

    def require_manager
      return if current_user.can_manage?

      redirect_to root_path
    end
  end
end
