class Manage::FinishersController < Manage::ManageController

  before_action :get_project, only: [:index, :map, :card]
  require 'csv'
  def index
    respond_to do |format|
      skill = Skill.find(params[:skill_id]) if params[:skill_id].present?
      product = Product.find(params[:product_id]) if params[:product_id].present?
      @title = ['Loose Ends - Manage - Finishers', params[:search].present? ? "'#{params[:search]}'" : nil, params[:country], params[:state], skill&.name, product&.name, params[:sort].present? ? "sort by #{params[:sort]}" : nil].reject(&:blank?).join(' ')
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
        if params[:country].present?
          @states = Finisher.where(country: params[:country]).distinct.pluck(:state).reject(&:blank?).sort
        else
          @states = Finisher.distinct.pluck(:state).reject(&:blank?).sort
        end
        @existing_countries = Finisher.distinct.pluck(:country).reject(&:blank?).sort
        @countries = ISO3166::Country.all.select{ |c| @existing_countries.include?(c.alpha2) }.map{ |c| [c.iso_short_name, c.alpha2]}.sort_by{|c| I18n.transliterate(c[0])}
      end
    end
  end

  def map
    @title = "Loose Ends - Manage - Finishers Map"
    params[:radius] ||= 50
    results = Geocoder.search(params[:near])
    if results.first
      @finishers = Finisher.geocoded.near(results.first.coordinates, params[:radius])
      if params[:skill_id].present?
        @finishers = @finishers.joins(:assessments).where(:assessments => { skill_id: params[:skill_id], rating: 1.. })
        @skill_id = params[:skill_id]
      end
      @center = results.first.coordinates
    end
  end

  def show
    @finisher = Finisher.find(params[:id])
    @title = "Loose Ends - Manage - Finishers - #{@finisher.chosen_name}"
  end

  def card
    @finisher = Finisher.find(params[:id])
    respond_to do |format|
      format.html do
        render layout: false
      end
    end
  end

  def edit
    @finisher = Finisher.find(params[:id])
    @title = "Loose Ends - Manage - Edit Finisher - #{@finisher.chosen_name}"
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
    params.require(:finisher).permit(:admin_notes,
                                     :phone_number,
                                     :approved,
                                     :unavailable,
                                     :joined_on,
                                     :chosen_name,
                                     :dominant_hand,
                                     :street,
                                     :street_2,
                                     :city,
                                     :state,
                                     :country,
                                     :postal_code,
                                     :has_workplace_match,
                                     :workplace_name)
  end

  private

  def get_project
    if params[:project_id]
      @project = Project.find(params[:project_id])
    end
  end

end
