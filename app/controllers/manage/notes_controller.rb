# frozen_string_literal: true

# ProjectNote was deprecated in favor of Note (polymorphic)
#
module Manage
  class NotesController < Manage::ManageController
    before_action :get_project, except: [:index]

    def index
      @notes = Note.for_assignment
                   .order(created_at: :desc)
                   .paginate(page: params[:page], per_page: params[:per_page])
    end

    def create
      @note = @project.notes.new(notes_params)
      @note.user = current_user
      @note.save

      update_last_contacted! if params[:finisher_contact]

      respond_to do |format|
        format.turbo_stream {}
      end
    end

    def destroy
      @note = @project.notes.find(params[:id])
      @note.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@note) }
      end
    end

    protected

    def get_project
      @project = Project.find(params[:project_id])
    end

    def notes_params
      params.require(:note).permit([:text])
    end

    def update_last_contacted!
      return if @project.active_finisher.blank?

      assignment = @project.assignments.where(finisher: @project.active_finisher).first
      return if assignment.blank?

      assignment.update_attribute!(:last_contacted_at, Time.zone.now)
    end
  end
end
