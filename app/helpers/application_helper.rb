# frozen_string_literal: true

module ApplicationHelper
  def fa_icon(icon_name, options = {})
    content_tag(:i, nil, options.merge(class: "fa fa-#{icon_name}"))
  end

  # For prepending DEVELOPMENT, TEST, or STAGING to page.title & elsewhere
  # (remember:  staging environment is RAILS_ENV=production)
  def display_env
    ENV['RAILS_ENV_DISPLAY'] == 'production' ? "" : "#{ENV['RAILS_ENV_DISPLAY'].upcase} "
  end
end
