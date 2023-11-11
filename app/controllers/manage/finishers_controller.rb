class Manage::FinishersController < Manage::ManageController
  require 'csv'
  def index
    respond_to do |format|
      skill = Skill.find(params[:skill_id]) if params[:skill_id].present?
      product = Product.find(params[:product_id]) if params[:product_id].present?
      @title = ['Finishers', params[:search].present? ? "'#{params[:search]}'" : nil, params[:country], params[:state], skill&.name, product&.name, params[:sort].present? ? "sort by #{params[:sort]}" : nil].reject(&:blank?).join(' ')
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=#{@title.parameterize}-#{DateTime.now.strftime("%Y-%m-%d-%H%M")}.csv"
        @finishers = Finisher.search(params)
      end
      format.html do
        first = Finisher.order(:joined_on).first.joined_on.beginning_of_month
        last = Date.today.beginning_of_month
        @months = (first..last).map{ |date| date.strftime("%Y-%m-01") }.uniq.reverse
        @finishers = Finisher.search(params).paginate(page: params[:page])
        @stateQuery = Finisher.where.not(state: "").order(:state).load_async
        if params[:country].present?
          @stateQuery = @stateQuery.where(country: params[:country])
        end
        @states = @stateQuery.pluck(:state).uniq
        @existing_countries = Finisher.where.not(country: "").order(:country).load_async.pluck(:country).uniq
        @countries = ISO3166::Country.all.select{ |c| @existing_countries.include?(c.alpha2) }.map{ |c| [c.iso_short_name, c.alpha2]}.sort_by{|c| I18n.transliterate(c[0])}
      end
    end
  end

  def map
    results = Geocoder.search(params[:near])
    if results.first
      @finishers = Finisher.geocoded.near(results.first.coordinates, 100)
      @center = results.first.coordinates
    end
  end

  def show
    @finisher = Finisher.find(params[:id])
    @title = @finisher.chosen_name
  end

  def edit
    @finisher = Finisher.find(params[:id])
    @title = "Edit " + @finisher.chosen_name
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
