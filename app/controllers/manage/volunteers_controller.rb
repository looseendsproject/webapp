class Manage::VolunteersController < Manage::ManageController
  def index
    @volunteers = Volunteer.search(params).paginate(page: params[:page])
    @stateQuery = Volunteer.where.not(state: "").order(:state).load_async
    if params[:country].present?
      @stateQuery = @stateQuery.where(country: params[:country])
    end
    @states = @stateQuery.pluck(:state).uniq
    @countries = Volunteer.where.not(country: "").order(:country).load_async.pluck(:country).uniq
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
      redirect_to [:manage, @volunteer]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected


  def volunteer_params
    params.require(:volunteer).permit(:admin_notes, :approved, :chosen_name, :street, :street_2, :city, :state, :country, :postal_code)
  end

end
