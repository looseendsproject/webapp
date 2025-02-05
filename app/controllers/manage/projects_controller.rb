# frozen_string_literal: true

module Manage
  class ProjectsController < Manage::ManageController
    def index
      @title = "Loose Ends - Manage - Projects"
      @status = params[:status] || "ready to match"
      if params[:status].present?
        @projects = Project.has_status(params[:status])

        # Additional filter for `ready_status` if `status` is "ready to match"
        if params[:status] == "ready to match" && params[:ready_status].present?
          @projects = @projects.where(ready_status: params[:ready_status])
        end

        # Additional filter for `in_process_status` if `status` is "in process"
        if params[:status] == "in process" && params[:in_process_status].present?
          @projects = @projects.where(in_process_status: params[:in_process_status])
        end
      else
        @projects = Project.has_status([
                                         "drafted",
                                         "proposed",
                                         "submitted via google",
                                         "project confirm email sent",
                                         "ready to match",
                                         "finisher invited",
                                         "project accepted/waiting on terms",
                                         "introduced",
                                         "in process",
                                         "finished/not returned",
                                         "done",
                                         "unresponsive",
                                         "on hold",
                                         "will not do",
                                         "waiting for return to rematch",
                                         "weird circumstance"
                                       ])
      end
      @projects = @projects.has_assigned(params[:assigned]) if params[:assigned].present?
      @projects = @projects.where(manager_id: params[:project_manager]) if params[:project_manager].present?

      # Add filters for checkbox attributes
      %i[joann_helped urgent influencer group_project press privacy_needed].each do |attr|
        @projects = @projects.where(attr => params[attr] == "true") if params[attr].present?
      end

      @projects = @projects.paginate(page: params[:page])
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
        redirect_to [:manage, @project]
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

    def project_params
      params.require(:project).permit(
        :manager_id,
        :name,
        :phone_number,
        :description,
        :more_details,
        :status,
        :ready_status,
        :in_process_status,
        :street,
        :street_2,
        :city,
        :state,
        :country,
        :postal_code,
        :craft_type,
        :has_pattern,
        :material_type,
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
        in_home_pets: [],
        append_crafter_images: [],
        append_project_images: [],
        append_pattern_files: [],
        append_material_images: []
      )
    end
  end
end
