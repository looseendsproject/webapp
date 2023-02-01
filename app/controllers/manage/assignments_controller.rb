class Manage::AssignmentsController < Manage::ManageController

  before_action :get_project

  def index

  end

  def show

  end

  def create
    @assignment = @project.assignments.new(create_assignment_params)
    @assignment.started_at = DateTime.now
    if @assignment.save
      redirect_to manage_projects_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update

  end

  protected

  def get_project
    @project = Project.find(params[:project_id])
  end

  def create_assignment_params
    params.require(:assignment).permit([:volunteer_id])
  end

  def update_assignment_params
    params.require(:assignment).permit([:ended])
  end
end
