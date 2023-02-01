class Admin::VolunteersController < Admin::AdminController
  def index
    @volunteers = Volunteer.paginate(page: params[:page])
  end

  def show
    @volunteer = Volunteer.find(params[:id])
  end

  def edit
    @volunteer = Volunteer.find(params[:id])
  end

  def update
    @volunteer = Volunteer.find(params[:id])
    @volunteer.update!(volunteer_params)
    redirect_to [:admin, @volunteer]
  end

  private

  def volunteer_params
    params.require(:volunteer).permit(:approved)
  end

end
