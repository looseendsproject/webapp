class Manage::FinishersController < Manage::ManageController
  def index
    @finishers = Finisher.search(params).paginate(page: params[:page])
    @stateQuery = Finisher.where.not(state: "").order(:state).load_async
    if params[:country].present?
      @stateQuery = @stateQuery.where(country: params[:country])
    end
    @states = @stateQuery.pluck(:state).uniq
    @existing_countries = Finisher.where.not(country: "").order(:country).load_async.pluck(:country).uniq
    @countries = ISO3166::Country.all.select{ |c| @existing_countries.include?(c.un_locode) }.map{ |c| [c.iso_short_name, c.un_locode]}
  end

  def show
    @finisher = Finisher.find(params[:id])
  end

  def edit
    @finisher = Finisher.find(params[:id])
  end

  def update
    @finisher = Finisher.find(params[:id])
    if @finisher.update(finisher_params)
      redirect_to [:manage, @finisher]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected


  def finisher_params
    params.require(:finisher).permit(:admin_notes, :approved, :unavailable, :joined_on, :chosen_name, :dominant_hand, :street, :street_2, :city, :state, :country, :postal_code)
  end

end
