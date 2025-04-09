# frozen_string_literal: true

class AssignmentsController < AuthenticatedController
  before_action :sanitize_params, only: :record_check_in
  after_action :alert_manager, only: [:record_check_in]

  # The values for sentiment radio buttons on check_in form
  # require_text: true will make note.text required
  #
  SENTIMENT_OPTIONS = [
    {
      sentiment_value: "well",
      textarea_label: "Great! Tell us more if you'd like",
      require_text: false
    },
    {
      sentiment_value: "not great",
      textarea_label: "Sorry to hear that. Tell us more and your Project Manager will contact you.",
      require_text: true
    },
    {
      sentiment_value: "no progress",
      textarea_label: "OK. We will check back later. Leave a note if you'd like.",
      require_text: false
    }
  ]

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
      render :check_in, status: :unprocessable_entity,
        flash: { alert: "Something went wrong. Contact support." }
    end
  end

  # note_path
  def thank_you; end

  private

    def sanitize_params
      @assignment_id = params.expect(:id)
      @note_params = params.expect(note: [:sentiment, :text])
    end

    def alert_manager

    end
end
