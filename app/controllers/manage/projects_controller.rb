# frozen_string_literal: true

require "csv"

module Manage
  class ProjectsController < Manage::ManageController
    before_action :redirect_to_saved_view, only: :index
    before_action :save_view_by_name, only: :index

    def index
      @title = "Loose Ends - Manage - Projects"
      @projects = Project.search(params)
                         .includes(:finishers)
                         .left_outer_joins(:assignments)
                         .group("projects.id")

      respond_to do |format|
        format.csv { add_csv_headers }
        format.html do
          @projects = @projects.paginate(page: params[:page], per_page: params[:per_page])
          @status_options_for_select = status_options_for_select
          @country_options_for_select = country_options_for_select
        end
      end
    end

    def show
      @project = Project.find(params[:id])
      @title = "Loose Ends - Manage - Projects - #{@project.name}"
    end

    def new
      @title = "Loose Ends - Manage - New Project"
      @project = Project.new
    end

    def edit
      @project = Project.find(params[:id])
      @title = "Loose Ends - Manage - Edit Project - #{@project.name}"
    end

    def create
      @project = Project.new(project_params)
      if @project.save
        redirect_to [:manage, @project]
      else
        render "new"
      end
    end

    def update
      @project = Project.find(params[:id])

      if @project.update(project_params)
        respond_to do |format|
          format.html { redirect_to [:manage, @project] }
          format.turbo_stream { turbo_stream }
        end
      else
        render "edit"
      end
    end

    def destroy
      @project = Project.find(params[:id])
      return unless @project.destroy

      redirect_to %i[manage projects]
    end

    def remove_saved_view
      return unless params[:remove_view].present?

      project_view = current_user.project_views.find(params[:remove_view])
      project_view.destroy
      flash[:notice] = "View removed"

      redirect_to manage_projects_path
    end

    protected

    def add_csv_headers
      response.headers["Content-Type"] = "text/csv"
      response.headers["Content-Disposition"] =
        "attachment; filename=#{@title.parameterize}-#{DateTime.now.strftime("%Y-%m-%d-%H%M")}.csv"
    end

    def status_options_for_select
      status_counts = Project.group(:status).count

      Project::STATUSES.values.map do |status|
        ["#{status}#{if status_counts[status].to_i.positive?
                       " (#{status_counts[status]})"
                     else
                       ""
                     end}", status]
      end
    end

    def country_options_for_select
      @project_countries = Project.distinct.pluck(:country).compact_blank.sort
      @countries = ISO3166::Country.all.select do |c|
        @project_countries.include?(c.alpha2)
      end
      @countries.map { |c| [c.iso_short_name, c.alpha2] }
                .sort_by { |c| I18n.transliterate(c[0]) }
    end

    def redirect_to_saved_view
      return unless load_view_name = params[:load_view]

      project_view = current_user.project_views.find(load_view_name)
      view_params = {}
      project_view.query.each do |query_predicate|
        view_params[query_predicate["field"]] = query_predicate["value"]
      end
      redirect_to manage_projects_path(view_params)
    end

    def save_view_by_name
      return if params[:save_view].blank?

      new_view_name = params[:save_view].strip

      query_params = params.permit(:manager_id, :last_contacted_at, :country,
                                   :search, :view, :sort, status: []).to_h
      if query_params.empty?
        flash[:notice] = "Cannot save an empty query view"
        redirect_to manage_projects_path
        return
      end

      project_view = current_user.project_views.find_or_initialize_by(name: new_view_name)
      project_view.query = query_params.map { |k, v| { field: k, value: v } }
      project_view.save!
      flash[:notice] = "View saved as #{new_view_name}"

      # Redirect to the new view to avoid leaving it in the URL when parameters are changed
      redirect_to manage_projects_path(load_view: project_view.id)
    end

    def project_params
      params.require(:project).permit(
        :manager_id,
        :name,
        :phone_number,
        :description,
        :more_details,
        :status,
        :street,
        :street_2,
        :city,
        :state,
        :country,
        :postal_code,
        :craft_type,
        :has_pattern,
        :material_type,
        :material_brand,
        :has_materials,
        :crafter_name,
        :crafter_description,
        :crafter_dominant_hand,
        :recipient_name,
        :can_publicize,
        :can_use_first_name,
        :terms_of_use,
        :no_smoke,
        :no_cats,
        :no_dogs,
        :has_smoke_in_home,
        :help_company,
        :company_helped,
        :urgent,
        :influencer,
        :group_project,
        :press,
        :privacy_needed,
        :group_manager_id,
        :press_region,
        :press_outlet,
        :needs_attention,
        in_home_pets: [],
        append_crafter_images: [],
        append_project_images: [],
        append_pattern_files: [],
        append_material_images: []
      )
    end
  end
end
