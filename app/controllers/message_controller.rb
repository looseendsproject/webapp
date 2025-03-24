# frozen_string_literal: true

class MessageController < AuthenticatedController

  # GET /message
  def show
    @message = Message.find(params[:id])

    # TODO allow regular user to see his/her own messages
    if current_user.admin? || current_user.manager?
      render 'messages/show'
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
