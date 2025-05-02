# frozen_string_literal: true

require "csv"

module Manage
  class FinishersController < Manage::ManageController
    before_action :get_project, only: %i[index map card]

    def index
      respond_to do |format|
        skill = Skill.find(params[:skill_id]) if params[:skill_id].present?
        product = Product.find(params[:product_id]) if params[:product_id].present?
        @title = ["Loose Ends - Manage - Finishers", params[:search].present? ? "'#{params[:search]}'" : nil,
                  params[:country], params[:state], skill&.name, product&.name, params[:sort].present? ? "sort by #{params[:sort]}" : nil].compact_blank.join(" ")
        format.csv do
          response.headers["Content-Type"] = "text/csv"
          response.headers["Content-Disposition"] =
            "attachment; filename=#{@title.parameterize}-#{DateTime.now.strftime("%Y-%m-%d-%H%M")}.csv"
          @finishers = Finisher.includes(:user).select(:id, :user_id, :first_name, :last_name, :email,
                                                       :has_workplace_match).search(params)
        end
        format.html do
          first_finisher = Finisher.order(:joined_on).first
          first = first_finisher.joined_on&.beginning_of_month || first_finisher.created_at.beginning_of_month
          last = Time.zone.today.beginning_of_month
          @months = (first.to_datetime..last.to_datetime).map { |date| date.strftime("%Y-%m-01") }.uniq.reverse

          # Getting the list of finishers is VERY performance sensitive.  Don't try to
          # get all associated records here.  Let the partials do the queries.
          @finishers = Finisher.search(params).paginate(page: params[:page])

          @states = if params[:country].present?
                      Finisher.where(country: params[:country]).distinct.pluck(:state).compact_blank.sort
                    else
                      Finisher.distinct.pluck(:state).compact_blank.sort
                    end
          @existing_countries = Finisher.distinct.pluck(:country).compact_blank.sort
          @countries = ISO3166::Country.all.select do |c|
            @existing_countries.include?(c.alpha2)
          end.map { |c| [c.iso_short_name, c.alpha2] }.sort_by { |c| I18n.transliterate(c[0]) }
        end
      end
    end

    def map
      @title = "Loose Ends - Manage - Finishers Map"
      params[:radius] ||= 50
      results = Geocoder.search(params[:near])
      return unless results.first

      @finishers = Finisher.geocoded.near(results.first.coordinates, params[:radius]).includes(:rated_assessments, :user)
      if params[:skill_id].present?
        @finishers = @finishers.joins(:assessments).where(assessments: { skill_id: params[:skill_id], rating: 1.. })
        @skill_id = params[:skill_id]
      end
      @center = results.first.coordinates

      respond_to do |format|
        format.csv do
          response.headers["Content-Type"] = "text/csv"
          response.headers["Content-Disposition"] =
            "attachment; filename=finishers-map-#{DateTime.now.strftime("%Y-%m-%d-%H%M")}.csv"
          render :index and return
        end
        format.html
      end
    end

    def show
      @finisher = Finisher.find(params[:id])
      unless @finisher.inbound_email_address.present? # assign inbound_email_address on action
        @finisher.valid?
        @finisher.save!
        @finisher.reload
      end
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

    def search
      return render json: [] if params[:term].blank?

      # Fetch finishers matching the search term (case insensitive)
      finishers = Finisher
                  .where("chosen_name ILIKE ?", "%#{params[:term]}%")
                  .limit(20)
                  .select(:id, :chosen_name)

      render json: finishers.map { |f| { id: f.id, name: f.chosen_name } }
    end

    protected

    def finisher_params
      params.require(:finisher).permit(:admin_notes,
                                       :phone_number,
                                       :approved,
                                       :unavailable,
                                       :confirm_email,
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
                                       :has_volunteer_time_off,
                                       :emergency_contact_name,
                                       :emergency_contact_relation,
                                       :emergency_contact_phone_number,
                                       :emergency_contact_email,
                                       :workplace_name)
    end

    private

    def get_project
      return unless params[:project_id]

      @project = Project.find(params[:project_id])
    end
  end
end
