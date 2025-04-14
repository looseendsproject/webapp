# frozen_string_literal: true

require "test_helper"

module Manage
  class JobLogsControllerTest < ActionDispatch::IntegrationTest

    def setup
      sign_in(users(:admin))
      @log = JobLog.first
    end

    test "show shows" do
      get "/manage/job_logs/#{@log.id}"
      assert_response :success
      assert_match "Hic sequi vel. Ipsa sapiente fugit.", response.body.to_s
    end
  end
end

