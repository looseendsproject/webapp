class ProjectsController < ApplicationController

  before_action :authenticate_user!

  def index
  end

  def show
    @project = Project.find(params[:id])
  end

  def edit
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

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end


end
