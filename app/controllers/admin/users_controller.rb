# frozen_string_literal: true

module Admin
  class UsersController < Admin::AdminController
    def index
      @users = User.search(params).paginate(page: params[:page])
      @title = "Loose Ends - Admin - Users"
    end

    def assume_identity
      user = User.find(params[:id])
      sign_in user
      redirect_to :root
    end

    def show
      @user = User.find(params[:id])
      @title = "Loose Ends - Admin - Users - #{@user.name}"
    end

    def edit
      @user = User.find(params[:id])
      @title = "Loose Ends - Admin - Edit User - #{@user.name}"
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to [:admin, @user]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      return unless @user.destroy

      redirect_to %i[admin users]
    end

    private

    def user_params
      params.require(:user).permit(:role, :email, :is_project_manager)
    end
  end
end
