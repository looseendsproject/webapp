# frozen_string_literal: true

module Manage
  class AssignmentUpdatesController < ApplicationController
    def create
      @assignment = Assignment.find(params[:assignment_id])
      @assignment_update = AssignmentUpdate.new(assignment_update_params)
      @assignment_update.user = current_user
      @assignment_update.assignment = @assignment
      return unless @assignment_update.save

      redirect_to [:manage, @assignment]
    end

    def destroy
      @assignment_update = AssignmentUpdate.find(params[:id])
      @assignment_udpate.destroy
    end

    private

    def assignment_update_params
      params.require(:assignment_update).permit(:description)
    end
  end
end
