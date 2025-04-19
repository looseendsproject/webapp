# frozen_string_literal: true

module Manage
  class DashboardsController < Manage::ManageController

    # GET /manage/failed_inbound_emails
    def failed_inbound_emails
      @failed_inbound_emails = ActionMailbox::InboundEmail.where("status > ?", 2)
    end
  end
end
