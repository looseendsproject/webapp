module ApplicationHelper
  def fa_icon icon_name, options = {}
    return content_tag(:i, nil, options.merge(:class => "fa fa-#{icon_name}"))
  end

  # Prepends DEVELOPMENT, TEST, or STAGING to page.title
  # null RAILS_DISPLAY_ENV or 'production' does not change title
  def display_env
    unless ENV['RAILS_DISPLAY_ENV'].blank? || ENV['RAILS_DISPLAY_ENV'] == 'production'
      return "#{ENV['RAILS_DISPLAY_ENV'].upcase} "
    end
    ''
  end
end