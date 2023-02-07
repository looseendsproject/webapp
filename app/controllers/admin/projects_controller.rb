class Admin::ProjectsController < Admin::AdminController


  def index
    @projects = Project.paginate(page: params[:page])
  end

  def show
    @project = Project.find(params[:id])
    render 'projects/show'
  end

  def edit
    @project = Project.find(params[:id])
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
    project = Project.find(params[:id])
    project.update!(project_params)
    redirect_to project
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, project_images: [], pattern_images: [], material_images: [])
  end


end
