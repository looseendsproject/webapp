# frozen_string_literal: true

module ApplicationHelper
  def fa_icon(icon_name, options = {})
    content_tag(:i, nil, options.merge(class: "fa fa-#{icon_name}"))
  end

  # Prepends DEVELOPMENT, TEST, or STAGING to page.title
  # null RAILS_DISPLAY_ENV or 'production' does not change title
  def display_env
    return "#{ENV["RAILS_DISPLAY_ENV"].upcase} " unless ENV["RAILS_DISPLAY_ENV"].blank? || Rails.env.production?

    ""
  end
end
