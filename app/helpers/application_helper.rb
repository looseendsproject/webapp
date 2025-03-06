# frozen_string_literal: true

module ApplicationHelper
  def fa_icon(icon_name, options = {})
    content_tag(:i, nil, options.merge(class: "fa fa-#{icon_name}"))
  end

  # For prepending DEVELOPMENT, TEST, or STAGING to page.title & elsewhere
  def display_env
    Rails.env.production? ? "" : "#{Rails.env.upcase} "
  end
end
