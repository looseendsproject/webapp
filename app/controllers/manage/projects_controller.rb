# frozen_string_literal: true

require "csv"

module Manage
  class ProjectsController < Manage::ManageController
    helper_method :suggested_actions?

    def index
      @title = "Loose Ends - Manage - Projects"
      @projects = Project.search(params).includes(:finishers)

      respond_to do |format|
        format.csv { add_csv_headers }
        format.html do
          @projects = @projects.paginate(page: params[:page], per_page: params[:per_page])
          @status_options_for_select = status_options_for_select
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

    def suggested_actions?
      false # TODO: Implement this method
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
        :joann_helped,
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
