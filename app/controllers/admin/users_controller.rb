class Admin::UsersController < Admin::AdminController
  def index
    @users = User.search(params).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update!(user_params)
    redirect_to [:admin, @user]
  end

  private

  def user_params
    params.require(:user).permit(:role)
  end

end
