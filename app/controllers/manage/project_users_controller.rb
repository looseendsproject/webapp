# frozen_string_literal: true

module Manage
  class ProjectUsersController < Manage::ManageController
    before_action :set_project
    before_action :set_user, only: [:assign_owner]

    def index
      @users = User.all

      # Search by name or email
      if params[:search].present?
        query = "%#{params[:search]}%"
        @users = @users.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", query, query, query)
      end

      # Sort by name or creation date
      case params[:sort]
      when 'name'
        @users = @users.order(:first_name, :last_name)
      when 'date'
        @users = @users.order(created_at: :desc)
      else
        @users = @users.order(created_at: :desc)
      end

      @users = @users.paginate(page: params[:page], per_page: 25)
    end

    def assign_owner
      if @project.update(user: @user)
        flash[:notice] = "#{@user.name} has been assigned as the project owner."
      else
        flash[:alert] = "Failed to assign project owner."
      end
      redirect_to manage_project_users_path(@project)
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_user
      @user = User.find(params[:id])
    end
  end
end
