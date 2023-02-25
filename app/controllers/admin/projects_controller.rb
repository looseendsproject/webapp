class Admin::ProjectsController < Admin::AdminController


  def index

    @projects = Project.all
    if (params[:status])
      @projects = @projects.where({ status: params[:status]})
    end
    @projects.paginate(page: params[:page])
  end

  def show
    @project = Project.find(params[:id])
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    project = Project.find(params[:id])
    project.update!(project_params)
    redirect_to admin_project_path(project)
  end

  private

  def project_params
    params.require(:project).permit(:status)
  end


end
