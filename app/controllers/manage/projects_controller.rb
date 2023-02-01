class Manage::ProjectsController < Manage::ManageController
  def index
    @projects = Project.paginate(page: params[:page])
  end

  def show
    @project = Project.find(params[:id])
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
  end
end
