# frozen_string_literal: true

class AssignmentsController < AuthenticatedController
  before_action :sanitize_params, only: :record_check_in
  after_action :alert_manager, :update_last_contacted_at, only: [:record_check_in]

  # GET /assignment/:id/check_in
  def check_in
    @assignment = current_user.finisher.assignments.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @assignment.present?

    @note = @assignment.notes.new(user_id: current_user.id)
  end

  # POST /assignment/:id/check_in
  def record_check_in
    assignment = current_user.finisher. assignments.find(@assignment_id)
    @note = assignment.notes.new(@note_params)
    @note.user_id = current_user.id

    if @note.save
      redirect_to thank_you_path
    else
      render :check_in, status: :unprocessable_entity
    end
  end

  # note_path
  def thank_you; end

  private

    def sanitize_params
      @assignment_id = params.expect(:id)
      @note_params = params.require(:note).permit(:sentiment, :text)
    end

    def alert_manager
      return unless @note.negative?

      set_project_needs_attention
      ProjectMailer.with(resource: @note.notable).alert_manager.deliver_later
    end

    def update_last_contacted_at
      @note.notable.update_attribute(:last_contacted_at, Time.zone.now)
    end

    def set_project_needs_attention
      @note.notable.project.update!(needs_attention: 'negative_sentiment')
    end
end
