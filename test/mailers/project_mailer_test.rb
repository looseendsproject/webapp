# frozen_string_literal: true

require "test_helper"

class ProjectMailerTest < ActionMailer::TestCase

  def setup
    @assignment = assignments(:knit_active)
  end

  test "alert_manager sends to the manager" do
    ProjectMailer.with(resource: @assignment).alert_manager.deliver_now

    assert_equal @assignment.project.manager.email, ActionMailer::Base.deliveries.last.to[0]
    assert_match "NEEDS ATTENTION", ActionMailer::Base.deliveries.last.subject
  end
end
