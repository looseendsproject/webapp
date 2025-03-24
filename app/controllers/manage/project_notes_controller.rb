# frozen_string_literal: true

module Manage
  class ProjectNotesController < Manage::ManageController
    before_action :get_project

    def create
      @project_note = @project.project_notes.new(project_notes_params)
      @project_note.user = current_user
      @project_note.save

      update_last_contacted! if params[:finisher_contact]

      respond_to do |format|
        format.turbo_stream {}
      end
    end

    def destroy
      @project_note = @project.project_notes.find(params[:id])
      @project_note.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@project_note) }
      end
    end

    protected

    def get_project
      @project = Project.find(params[:project_id])
    end

    def project_notes_params
      params.require(:project_note).permit([:description])
    end

    def update_last_contacted!
      return if @project.active_finisher.blank?

      assignment = @project.assignments.where(finisher: @project.active_finisher).first
      return if assignment.blank?

      assignment.update_attribute!(:last_contacted_at, Time.zone.now)
    end
  end
end
