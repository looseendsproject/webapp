class Manage::VolunteersController < Manage::ManageController
  def index
    @volunteers = Volunteer.search(params).paginate(page: params[:page])
  end

  def show
    @volunteer = Volunteer.find(params[:id])
  end

  def edit
    @volunteer = Volunteer.find(params[:id])
  end

  def update
    @volunteer = Volunteer.find(params[:id])
    if @volunteer.update(volunteer_params)
      redirect_to volunteer_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected


  def volunteer_params
    params.require(:volunteer).permit(:admin_notes)
  end

end
