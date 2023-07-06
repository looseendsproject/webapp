class AuthenticatedController < ApplicationController

  before_action :require_current_user

  def require_current_user
    if !current_user
      redirect_to root_path
    end
  end

end
