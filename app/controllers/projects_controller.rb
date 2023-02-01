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
    project = current_user.projects.find(params[:id])
    project.update!(project_params)
    redirect_to project
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, project_images: [], pattern_images: [], material_images: [])
  end


end
