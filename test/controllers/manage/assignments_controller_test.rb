# frozen_string_literal: true

require "test_helper"

module Manage
  class AssignmentsControllerTest < ActionController::TestCase
    setup do
      @user = users(:admin)
      sign_in @user
    end

    test "update can set status" do
      assignment = assignments(:knit_active)
      patch :update, params: { id: assignment.id, assignment: { status: "invited" } }

      assert_response :redirect
      assert_equal "invited", assignment.reload.status
    end

    test "update can clear status" do
      assignment = assignments(:knit_active)
      assignment.update!(status: "invited")
      patch :update, params: { id: assignment.id, assignment: { status: "" } }

      assert_response :redirect
      assert_nil assignment.reload.status
    end

    test "turbo stream update renders saved label on update" do
      assignment = assignments(:knit_active)
      patch :update, params: { id: assignment.id, assignment: { status: "invited" } }, format: :turbo_stream

      assert_response :success
      assert_match(/SAVED/, response.body)
    end

    test "turbo stream update renders NO saved label if nothing changed" do
      assignment = assignments(:knit_active)
      assignment.update!(status: "invited")
      patch :update, params: { id: assignment.id, assignment: { status: "invited" } }, format: :turbo_stream

      assert_response :success
      assert_no_match(/SAVED/, response.body)
    end
  end
end
