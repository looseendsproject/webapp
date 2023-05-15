class Manage::ProjectsController < Manage::ManageController
  def index
    @projects = Project.all
    if (params[:status])
      @projects = @projects.has_status(params[:status])
    end
    if (params[:assigned])
      @projects = @projects.has_assigned(params[:assigned])
    end
    @projects = @projects.paginate(page: params[:page])
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
