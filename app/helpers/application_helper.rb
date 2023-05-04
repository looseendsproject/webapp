module ApplicationHelper
  def fa_icon icon_name, options = {}
    return content_tag(:i, nil, options.merge(:class => "fa fa-#{icon_name}"))
  end
end