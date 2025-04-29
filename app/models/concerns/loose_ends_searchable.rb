# frozen_string_literal: true

require "active_support/concern"

# This module is used to create consistent search functionality
# for the User, Finisher and Project models.
module LooseEndsSearchable
  extend ActiveSupport::Concern

  included do
    class_attribute :_search_query_includes
    self._search_query_includes = []
    class_attribute :_search_query_joins
    self._search_query_joins = []
    class_attribute :_text_fields
    self._text_fields = []
    class_attribute :_since_field
    self._since_field = :created_at
    class_attribute :_sort_name_field
    self._sort_name_field = :last_name
    class_attribute :_default_sort
    self._default_sort = :name
  end

  class_methods do
    # Configuration method to specify the field to use for the since parameter.
    # Default is :created_at.
    #
    # Example:
    #  search_since_field :joined_on
    #
    # @param field [Symbol] the field to use for the since parameter
    def search_since_field(field)
      self._since_field = field
    end

    # Configuration method to specify the associations to include in the search query.
    # Default is an empty array.
    #
    # Example:
    # search_query_includes :projects, :finisher
    #
    # @param includes [Array<Symbol>] the associations to include in the search query
    def search_query_includes(*includes)
      self._search_query_includes = includes
    end

    # Configuration method to specify the associations to join in the search query.
    # Default is an empty array.
    #
    # Example:
    # search_query_joins :user
    #
    # @param joins [Array<Symbol>] the associations to join in the search query
    def search_query_joins(*joins)
      self._search_query_joins = joins
    end

    # Configuration method to specify the fields to search for text matches.
    # Default is an empty array.
    #
    # Example:
    # search_text_fields :first_name, :last_name, :email
    #
    # @param fields [Array<Symbol>] the fields to search for text matches
    def search_text_fields(*fields)
      self._text_fields = fields
    end

    # Configuration method to specify the field to use for sorting by name.
    # Default is :last_name.
    #
    # Example:
    # search_sort_name_field :first_name
    #
    # @param field [Symbol] the field to use for sorting by name
    def search_sort_name_field(field)
      self._sort_name_field = field
    end

    # Configuration method to specify the default sort order.
    # Default is :name.
    #
    # Example:
    # search_default_sort :date
    #
    #
    def search_default_sort(sort)
      self._default_sort = sort
    end

    # Search method to be used in the controller.
    def search(params)
      query = all
      query = with_shared_fields(query, params)
      query = with_user_fields(query, params) if self == User
      query = with_finisher_fields(query, params) if self == Finisher
      query = with_project_fields(query, params) if self == Project
      with_sort(query, params[:sort])
    end

    private

    def with_shared_fields(query, params)
      query = with_includes_and_joins(query)
      query = with_since(query, params[:since])
      query = with_skill_id(query, params[:skill_id])
      query = with_state(query, params[:state])
      query = with_country(query, params[:country])
      with_text_fields(query, params[:search])
    end

    def with_user_fields(query, params)
      with_role(query, params[:role])
    end

    def with_finisher_fields(query, params)
      query = with_product_id(query, params[:product_id])
      query = with_workplace_match(query, params[:has_workplace_match])
      with_available(query, params[:available])
    end

    def with_project_fields(query, params)
      query = with_assigned(query, params[:assigned])
      query = with_statuses(query, params)
      query = with_manager_id(query, params[:manager_id])
      with_project_boolean_attributes(query, params)
    end

    def with_includes_and_joins(query)
      return query if _search_query_includes.blank? && _search_query_joins.blank?

      result = query
      result = result.includes(_search_query_includes) if _search_query_includes.present?
      result = result.joins(_search_query_joins) if _search_query_joins.present?
      result
    end

    def with_text_fields(query, search)
      return query if search.blank?

      tokens = extract_tokens(search)
      clauses = []
      replacements = []
      tokens.each do |token|
        subclauses = []
        _text_fields.each do |field|
          subclauses << "#{field} iLike ?"
          replacements << "%#{token}%"
        end
        clauses << "(#{subclauses.join(" OR ")})"
      end

      query.where([clauses.join(" AND "), *replacements])
    end

    # Split search string into tokens, allowing for quoted phrases but remote the quotes
    # Examples:
    #    'john doe knit' => ["john", "doe", "knit"]
    #    '"jane doe" knit' => ["jane doe", "knit"]
    def extract_tokens(search)
      search.scan(/(?:\w|"[^"]*")+/).map { |token| token.delete('"') }
    end

    def with_since(query, since)
      return query if since.blank?

      since_date = Date.parse(since)
      query.where({ _since_field => since_date.. })
    end

    def with_role(query, role)
      return query if role.blank?

      query.where({ users: { role: role } })
    end

    def with_product_id(query, product_id)
      return query if product_id.blank?

      query.joins(:favorites).where({ favorites: { product_id: product_id } })
    end

    def with_skill_id(query, skill_id)
      return query if skill_id.blank?

      query.joins(:assessments).where({ assessments: { skill_id: skill_id, rating: 1.. } })
    end

    def with_available(query, available)
      return query if available.blank?

      if available == "yes"
        query.where.not({ unavailable: true })
      elsif available == "no"
        query.where({ unavailable: true })
      end
    end

    def with_assigned(query, assigned)
      return query if assigned.blank?

      if assigned === "true"
        query.joins(:assignments).distinct
      elsif assigned === "false"
        query.where.missing(:assignments)
      end
    end

    def with_workplace_match(query, has_workplace_match)
      return query if has_workplace_match != "1"

      query.where({ has_workplace_match: true })
    end

    def with_field_value(query, field, value)
      return query if value.blank?

      if value == "none"
        query.where({ field => nil })
      else
        query.where({ field => value })
      end
    end

    def with_state(query, state)
      with_field_value(query, :state, state)
    end

    def with_statuses(query, params)
      result = query
      result = if params[:status].blank?
                 result.ignore_inactive
               else
                 with_field_value(result, :status, params[:status])
               end
    end

    def with_manager_id(query, manager_id)
      with_field_value(query, :manager_id, manager_id)
    end

    def with_country(query, country)
      with_field_value(query, :country, country)
    end

    def with_project_boolean_attributes(query, params)
      result = query
      Project::BOOLEAN_ATTRIBUTES.each do |attr|
        result = result.where(attr => params[attr] == "true") if params[attr].present?
      end
      result
    end

    def with_sort(query, sort)
      custom_sorts = {
        "name" => "LOWER(#{_sort_name_field}) ASC",
        "name asc" => "LOWER(#{_sort_name_field}) ASC",
        "name desc" => "LOWER(#{_sort_name_field}) DESC",
        "date" => "#{_since_field} ASC",
        "date asc" => "#{_since_field} ASC",
        "date desc" => "#{_since_field} DESC"
      }

      if sort.present? && custom_sorts[sort].nil?
        # Form passed in something custom, so just use it
        query.order(sort)
      else
        query.order(sort.present? ? custom_sorts[sort] : custom_sorts[_default_sort])
      end
    end
  end
end
