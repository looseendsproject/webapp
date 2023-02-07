class ProjectsController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]

  def index
    @projects = current_user.projects
  end

  def show
    @project = current_user.projects.find(params[:id])
  end

  def edit
    @project = current_user.projects.find(params[:id])
  end

  def new
    @project = Project.new
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
    @project = current_user.projects.find(params[:id])
    if @project.update(project_params)
      redirect_to @project
    else
      render 'edit'
    end
  end

  private

  def project_params
    params.require(:project).permit(
      :name,
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
      :product_description,
      :has_pattern,
      :material_type,
      :material_description,
      :crafter_name,
      :crafter_description,
      :recipient_name,
      :can_publicize,
      :terms_of_use,
      crafter_images: [],
      project_images: [],
      pattern_images: [],
      material_images: []
    )
  end


end
