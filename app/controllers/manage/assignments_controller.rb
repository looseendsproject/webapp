class Manage::AssignmentsController < Manage::ManageController

  before_action :get_project, :only => [:new]

  def create
    @assignment = Assignment.new(create_assignment_params)
    @assignment.started_at = DateTime.now
    @assignment.user = current_user
    if @assignment.save
      redirect_to manage_project_path(@assignment.project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy
    respond_to do |format|
      format.turbo_stream
    end
  end

  def new
    @project = Project.find(params[:project_id])
    @finisher = Finisher.find(params[:finisher_id])
    @assignment = @project.assignments.new(project_id: @project.id, finisher_id: @finisher.id)
  end

  protected

  def get_project
    @project = Project.find(params[:project_id])
  end

  def create_assignment_params
    params.require(:assignment).permit([:project_id, :finisher_id])
  end

end
