# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class SearchableClass
  include LooseEndsSearchable

  class_attribute :all

  def includes(_associations)
    all
  end
end

class SearchableComplexClass < SearchableClass
  include LooseEndsSearchable

  search_since_field :joined_at
  search_query_includes :projects, :finisher
  search_text_fields :first_name, :last_name, :email
  search_sort_name_field :chosen_name
  search_default_sort "date asc"
end

class LooseEndsSearchableTest < ActiveSupport::TestCase
  setup do
    SearchableClass.all = Minitest::Mock.new("all")
    SearchableClass.all.expect(:order, SearchableClass.all, ["LOWER(last_name) ASC"])
  end

  test "Defines search method" do
    assert_respond_to(SearchableClass, :search)
  end

  test "Concern does not cross-pollinate configuration" do
    assert_not_equal(SearchableClass._search_query_includes, SearchableComplexClass._search_query_includes)
    assert_not_equal(SearchableClass._text_fields, SearchableComplexClass._text_fields)
    assert_not_equal(SearchableClass._since_field, SearchableComplexClass._since_field)
    assert_not_equal(SearchableClass._sort_name_field, SearchableComplexClass._sort_name_field)
    assert_not_equal(SearchableClass._default_sort, SearchableComplexClass._default_sort)
  end

  test "search method returns all records when no params" do
    results = SearchableClass.all

    assert_equal(results, SearchableClass.search({}))
  end

  test "search method filters by search" do
    search_param = "search"

    query_mock = Minitest::Mock.new("query")
    SearchableClass.all.expect(:includes, query_mock, [%i[projects finisher]])
    query_mock.expect(:where, query_mock,
                      [["first_name iLike :name OR last_name iLike :name OR email iLike :name",
                        { name: "#{search_param}%" }]])
    query_mock.expect(:order, query_mock, ["joined_at ASC"])

    SearchableComplexClass.search({ search: search_param })

    query_mock.verify
  end

  test "search method filters by since" do
    since_param = "1970-01-01"
    SearchableClass.all.expect(:where, SearchableClass.all, [{ created_at: Date.parse(since_param).. }])

    SearchableClass.search({ since: since_param })

    SearchableClass.all.verify
  end

  test "search method filters by role" do
    role_param = "admin"
    SearchableClass.all.expect(:where, SearchableClass.all, [{ users: { role: role_param } }])

    SearchableClass.search({ role: role_param })

    SearchableClass.all.verify
  end

  test "search method filters by state" do
    state_param = "CA"
    SearchableClass.all.expect(:where, SearchableClass.all, [{ state: state_param }])

    SearchableClass.search({ state: state_param })

    SearchableClass.all.verify
  end

  test "search method filters by country" do
    country_param = "US"
    SearchableClass.all.expect(:where, SearchableClass.all, [{ country: country_param }])

    SearchableClass.search({ country: country_param })

    SearchableClass.all.verify
  end

  test "search method filters by workplace_match" do
    workplace_match_param = "1"
    SearchableClass.all.expect(:where, SearchableClass.all, [{ has_workplace_match: true }])

    SearchableClass.search({ workplace_match: workplace_match_param })

    SearchableClass.all.verify
  end

  test "search method filters by available=NO" do
    available_param = "no"
    SearchableClass.all.expect(:where, SearchableClass.all, [{ unavailable: true }])

    SearchableClass.search({ available: available_param })

    SearchableClass.all.verify
  end

  test "search method filters by available=YES" do
    available_param = "yes"

    where_not_mock = Minitest::Mock.new("where_not")
    SearchableClass.all.expect(:where, where_not_mock, [])
    where_not_mock.expect(:not, SearchableClass.all, [{ unavailable: true }])

    SearchableClass.search({ available: available_param })

    where_not_mock.verify
  end

  test "search method filters by product_id" do
    product_id = 1

    query_mock = Minitest::Mock.new("query")
    SearchableClass.all.expect(:joins, query_mock, [:favorites])
    query_mock.expect(:where, SearchableClass.all, [{ favorites: { product_id: product_id } }])

    SearchableClass.search({ product_id: product_id })

    query_mock.verify
  end

  test "search method filters by skill_id" do
    skill_id = 1

    query_mock = Minitest::Mock.new("query")
    SearchableClass.all.expect(:joins, query_mock, [:assessments])
    query_mock.expect(:where, SearchableClass.all, [{ assessments: { skill_id: skill_id, rating: 1.. } }])

    SearchableClass.search({ skill_id: skill_id })

    query_mock.verify
  end
end
