# frozen_string_literal: true

module Manage
  class UsersController < Manage::ManageController
    before_action :authorize_manager!

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

    def show
      @user = User.find(params[:id])
    end

    def new
      @user = User.new
      @title = "Loose Ends - Manage - New User"
    end

    def edit
      @user = User.find(params[:id])
    end

    def create
      @user = User.new(user_params)
      if @user.save
        @user.send_reset_password_instructions
        redirect_to manage_users_path, notice: "User created successfully."
      else
        Rails.logger.debug "USER ERRORS: #{@user.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to manage_user_path(@user), notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def authorize_manager!
      redirect_to root_path, alert: "Not authorized" unless current_user.manager? || current_user.admin?
    end

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :phone,
        :heard_about_us,
        :do_not_work_with
      )
    end
  end
end
