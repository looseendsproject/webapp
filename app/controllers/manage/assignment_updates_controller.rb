class Manage::AssignmentUpdatesController < ApplicationController
  def destroy
    @assignment_update = AssignmentUpdate.find(params[:id])
    @assignment_udpate.destroy
  end

  def create
    @assignment = Assignment.find(params[:assignment_id])
    @assignment_update = AssignmentUpdate.new(assignment_update_params)
    @assignment_update.user = current_user
    @assignment_update.assignment = @assignment
    if @assignment_update.save
      redirect_to [:manage, @assignment]
    end
  end

  private

  def assignment_update_params
    return params.require(:assignment_update).permit(:description)
  end
end
