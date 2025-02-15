# frozen_string_literal: true

module Manage
  class AssignmentsController < Manage::ManageController
    def index
      @assignments = Assignment.all
    end

    def new
      @project = Project.find(params[:project_id])
      @finisher = Finisher.find(params[:finisher_id])
      @assignment = @project.assignments.new(project_id: @project.id, finisher_id: @finisher.id)
      @title = "Loose Ends - Manage - Assign Project - #{@project.name}"
    end

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

    def update
      @assignment = Assignment.find(params[:id])
      should_delete = params[:commit] == "Delete"

      if should_delete
        @assignment.destroy
      else
        @assignment.update(create_assignment_params)
      end

      respond_to do |format|
        format.html { redirect_to manage_project_path(@assignment.project) }
        format.turbo_stream do
          if should_delete
            render turbo_stream: turbo_stream.remove(@assignment)
          else
            turbo_stream
          end
        end
      end
    end

    def destroy
      @assignment = Assignment.find(params[:id])
      @assignment.destroy
      respond_to(&:turbo_stream)
    end

    protected

    def create_assignment_params
      params.require(:assignment).permit(%i[project_id finisher_id status])
    end
  end
end
