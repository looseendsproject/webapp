# frozen_string_literal: true

require "test_helper"

module Manage
  class AssignmentsControllerTest < ActionController::TestCase
    setup do
      @user = users(:admin)
      sign_in @user
    end

    test "create denormalizes manager_id" do
      old_assignment = assignments(:knit_active)
      old_assignment.project.manager_id = nil
      refute old_assignment.project.manager_id

      new_assignment = old_assignment.dup
      old_assignment.destroy
      assert_raises (ActiveRecord::RecordNotFound) {
        Assignment.find(old_assignment.id).present?
      }

      new_assignment.save!
      assert_equal new_assignment.created_by, new_assignment.project.manager_id
    end

    test "create through params" do
      params = { "assignment" => { "project_id"=>"1", "finisher_id"=>"2", "status"=>"accepted"}}
      Assignment.find(1).destroy
      refute Project.find(1).assignments.any?
      post :create, params: params
      assert_response :found
      assert_redirected_to "/manage/projects/1"
      assert Project.find(1).assignments.any?
    end

    test "update denormalizes manager_id" do
      assignment = assignments(:knit_active)
      assignment.project.manager_id = nil
      refute assignment.project.manager_id
      assert_equal 3, assignment.created_by
      assignment.update(started_at: Time.zone.now)
      assert_equal assignment.created_by, assignment.project.manager_id
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
      assert_select(".update-flash.visible", count: 1)
    end

    test "turbo stream update renders NO saved label if nothing changed" do
      assignment = assignments(:knit_active)
      assignment.update!(status: "invited")
      patch :update, params: { id: assignment.id, assignment: { status: "invited" } }, format: :turbo_stream

      assert_response :success
      assert_select(".update-flash.visible", count: 0)
    end
  end
end
