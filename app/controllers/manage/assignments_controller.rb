class Manage::AssignmentsController < Manage::ManageController

  before_action :get_project, :only => [:new, :create]

  def index
    @assignments = Assignment.all
  end

  def show
    @assignment = Assignment.find(params[:id])
  end

  def create
    @assignment = @project.assignments.new(create_assignment_params)
    @assignment.started_at = DateTime.now
    @assignment.user = current_user
    if @assignment.save
      redirect_to manage_projects_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update

  end

  def new
    @assignment = @project.assignments.new
  end

  protected

  def get_project
    @project = Project.find(params[:project_id])
  end

  def create_assignment_params
    params.require(:assignment).permit([:finisher_id])
  end

  def update_assignment_params
    params.require(:assignment).permit([:ended])
  end
end
