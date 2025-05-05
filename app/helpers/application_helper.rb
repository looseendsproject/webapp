# frozen_string_literal: true

module ApplicationHelper
  def fa_icon(icon_name, options = {})
    content_tag(:i, nil, options.merge(class: "fa fa-#{icon_name}"))
  end

  def availability_options(saved_value)
    options_for_select(['Yes', 'No', "I don't know"], { selected: saved_value || "I don't know" })
  end

  # For prepending DEVELOPMENT, TEST, or STAGING to page.title & elsewhere
  # (remember:  staging environment is RAILS_ENV=production)
  def display_env
    ENV['RAILS_ENV_DISPLAY'] == 'production' ? "" : "#{ENV['RAILS_ENV_DISPLAY'].upcase} "
  end
end
