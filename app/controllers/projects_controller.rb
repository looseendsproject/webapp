# frozen_string_literal: true

class ProjectsController < AuthenticatedController
  before_action :store_user_location!, if: :storable_location?

  before_action :get_project, only: %i[
    show
    edit_project
    edit_address
    edit_crafter
    update
    destroy
  ]

  def show; end

  def edit_address; end

  def edit_project; end

  def edit_crafter; end

  def new
    @project = Project.new
    @title = "Loose Ends - New Project"
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    if @project.save
      redirect_to @project
    else
      render "new"
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project
    elsif project_params[:phone_number]
      render "edit_address"
    else
      render "edit_project"
    end
  end

  def destroy
    if params[:project_image_id]
      image = @project.project_images.find(params[:project_image_id])
      if @project.project_images.size > 1
        Rails.env.production? ? image.purge : image.delete
      else
        flash.alert = "There must be at least one project image"
      end
      redirect_to @project
    end

    if params[:material_image_id]
      image = @project.material_images.find(params[:material_image_id])
      Rails.env.production? ? image.purge : image.delete
      redirect_to @project
    end

    if params[:crafter_image_id]
      image = @project.crafter_images.find(params[:crafter_image_id])
      Rails.env.production? ? image.purge : image.delete
      redirect_to @project
    end

    return unless params[:pattern_file_id]

    image = @project.pattern_files.find(params[:pattern_file_id])
    Rails.env.production? ? image.purge : image.delete
    redirect_to @project
  end

  private

  def project_params
    params.require(:project).permit(
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
      in_home_pets: [],
      append_crafter_images: [],
      append_project_images: [],
      append_pattern_files: [],
      append_material_images: []
    )
  end

  def get_project
    @project = current_user.projects.find_by(id: params[:id])
    redirect_to :root unless @project
  end
end
