class Manage::ManageController < ApplicationController

  before_action :authenticate_user!
  before_action :require_manager

  def require_manager
    if !current_user.can_manage?
      redirect_to root_path
    end
  end
end
