# frozen_string_literal: true

require "test_helper"

module Manage
  class NotesControllerTest < ActionController::TestCase
    setup do
      @user = users(:admin)

      assert_predicate(@user, :can_manage?)
      @project = projects(:one)
    end

    test "can create a note with a description" do
      sign_in @user
      post :create, params: { project_id: @project.id, note: { text: "This is a note" } },
                    format: :turbo_stream

      assert_response :success
      assert_equal(2, @project.notes.count)
      assert_equal("This is a note", @project.notes.last.text)
    end

    test "can create a note and mark as a finisher contact" do
      assert(@project.active_finisher, "Project must have an active finisher to test this feature")
      assignment = @project.assignments.where(finisher: @project.active_finisher).first
      assignment.last_contacted_at = nil # set up fixture

      assert_predicate(assignment.last_contacted_at, :blank?)

      sign_in @user
      post :create, params: { project_id: @project.id, note: { text: "This is a note" },
                              finisher_contact: true }, format: :turbo_stream

      assert_response :success
      assert_predicate(assignment.reload.last_contacted_at, :present?)
    end

    test "can delete a note" do
      sign_in @user
      note = @project.notes.create!(user: @user, text: "This is a note")

      assert_equal(2, @project.notes.count)

      delete :destroy, params: { project_id: @project.id, id: note.id }, format: :turbo_stream

      assert_response :success
      assert_equal(1, @project.notes.count)
    end

    test "can load the index of notes" do
      sign_in @user
      get :index

      assert_response :success
      assert_not_nil assigns(:notes)
      assert_template "manage/notes/index"
      assert_select "h1", text: "Finisher Notes by Date"
    end
  end
end
