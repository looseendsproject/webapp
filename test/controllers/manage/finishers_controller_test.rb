# frozen_string_literal: true

require "test_helper"

module Manage
  class FinishersControllerTest < ActionController::TestCase
    setup do
      @user = users(:admin)

      assert_predicate(@user, :can_manage?)
    end

    test "can render #show" do
      sign_in @user
      get :show, params: { id: 1 }

      assert_response :success
    end

    test "assigns inbound_email_address" do
      assert_not Finisher.find(2).inbound_email_address

      sign_in @user
      get :show, params: { id: 2 }

      assert_match(/finisher-\w{8}@localhost/, response.body)
    end

    test "search requires login" do
      get :search

      assert_redirected_to new_user_registration_path
    end

    test "search requires can_manage? access" do
      @user_without_manager = users(:basic)

      assert_not_predicate(@user_without_manager, :can_manage?)

      sign_in @user_without_manager
      get :search

      assert_redirected_to root_path
    end

    test "search with no parameters" do
      sign_in @user
      get :search

      assert_response :success
      assert_empty(response.parsed_body)
    end

    test "search with no matches" do
      sign_in @user
      get :search, params: { term: "xyz" }

      assert_response :success
      assert_empty(response.parsed_body)
    end

    test "search with parameters returning one match" do
      sign_in @user
      get :search, params: { term: "fran" }

      assert_response :success
      assert_equal([{ "id" => 2, "name" => "Franny" }], response.parsed_body)
    end

    test "search with parameters returning multiple matches" do
      sign_in @user
      get :search, params: { term: "f" }

      assert_response :success
      assert_equal([{ "id" => 2, "name" => "Franny" }], response.parsed_body)
    end

    test "does not allow SQL injection" do
      sign_in @user
      get :search, params: { term: "f;' DROP TABLE finishers; --" }

      assert_response :success
      assert_empty(response.parsed_body)
      assert_predicate(Finisher.count, :positive?)
    end

    test "map action" do
      sign_in @user
      get :map

      assert_response :success
    end

    test "map CSV export metadata" do
      sign_in @user
      get :map, format: :csv, params: { near: "123 Main St, Anytown, WA, 12345" }

      assert_response :success
      assert_equal("text/csv", response.content_type)
      assert_predicate(response.headers["Content-Disposition"], :present?)
    end

    test "map CSV export content" do
      sign_in @user
      get :map, format: :csv, params: { near: "123 Main St, Anytown, WA, 12345" }

      ["ID", "First Name", "Last Name", "Email", "Match", "Country"].each do |header|
        assert_includes(response.body, header)
      end
    end

    test "CSV export metadata" do
      sign_in @user
      get :index, format: :csv

      assert_response :success
      assert_equal("text/csv", response.content_type)
      assert_predicate(response.headers["Content-Disposition"], :present?)
    end

    test "CSV export content" do
      sign_in @user
      get :index, format: :csv

      ["ID", "First Name", "Last Name", "Email", "Match", "Country"].each do |header|
        assert_includes(response.body, header)
      end
    end

    test "can update if the finisher has volunteer time off" do
      sign_in @user

      finisher = finishers(:crocheter)
      params = {
        id: finisher.id,
        finisher: finisher.attributes.merge(
          "street" => "123 Main St",
          "city" => "Anytown",
          "state" => "WA",
          "postal_code" => "12345",
          "country" => "US",
          "has_volunteer_time_off" => true
        )
      }
      patch :update, params: params

      finisher.reload

      assert(finisher.has_volunteer_time_off)
    end

    test "can update user.confirmed_at" do
      sign_in @user

      finisher = finishers(:crocheter)
      params = {
        id: finisher.id,
        finisher: finisher.attributes.merge(
          "street" => "123 Main St",
          "city" => "Anytown",
          "state" => "WA",
          "postal_code" => "12345",
          "country" => "US",
          "confirm_email" => "1"
        )
      }
      patch :update, params: params

      finisher.reload

      assert_predicate(finisher.user, :confirmed?)
    end

    test "can view a finisher with too many finished_projects" do
      sign_in @user

      finisher = finishers(:crocheter)
      finisher.inbound_email_address = nil # force show to also save
      finisher.append_finished_projects = [fixture_file_upload("tiny.jpg")] * 15
      finisher.save!(validate: false)

      get :show, params: { id: finisher.id }

      assert_response :success
    end
  end
end
