# frozen_string_literal: true

module Manage
  class JobLogsController < Manage::ManageController

    def show
      @job_log = JobLog.find(params[:id])
    end
  end
end
