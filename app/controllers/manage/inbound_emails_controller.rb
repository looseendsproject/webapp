# frozen_string_literal: true

module Manage
  class InboundEmailsController < Manage::ManageController

    # GET /manage/inbound_emails
    def index
      @inbound_emails = ActionMailbox::InboundEmail.all
    end

  end
end
