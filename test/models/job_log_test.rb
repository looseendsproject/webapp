# frozen_string_literal: true

# == Schema Information
#
# Table name: job_logs
#
#  id         :bigint           not null, primary key
#  output     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class JobLogTest < ActiveSupport::TestCase

  test "since scope" do
    assert_equal 1, JobLog.since(3.days.ago).count
  end
end
