# frozen_string_literal: true

require "test_helper"

module Manage
  class ProjectNotesControllerTest < ActionController::TestCase
    setup do
      @user = users(:admin)

      assert_predicate(@user, :can_manage?)
      @project = projects(:one)
    end

    test "can create a note with a description" do
      sign_in @user
      post :create, params: { project_id: @project.id, project_note: { description: "This is a note" } },
                    format: :turbo_stream

      assert_response :success
      assert_equal(1, @project.project_notes.count)
      assert_equal("This is a note", @project.project_notes.first.description)
    end

    test "can create a note and mark as a finisher contact" do
      assert(@project.active_finisher, "Project must have an active finisher to test this feature")
      assignment = @project.assignments.where(finisher: @project.active_finisher).first

      assert_predicate(assignment.last_contacted_at, :blank?)

      sign_in @user
      post :create, params: { project_id: @project.id, project_note: { description: "This is a note" },
                              finisher_contact: true }, format: :turbo_stream

      assert_response :success
      assert_predicate(assignment.reload.last_contacted_at, :present?)
    end

    test "can delete a note" do
      sign_in @user
      note = @project.project_notes.create!(user: @user, description: "This is a note")

      assert_equal(1, @project.project_notes.count)

      delete :destroy, params: { project_id: @project.id, id: note.id }, format: :turbo_stream

      assert_response :success
      assert_equal(0, @project.project_notes.count)
    end
  end
end
