module ApplicationHelper
  def title(title)
    content_for :title, title
  end

  def omniauth_path(provider, query = {})
    "/auth/#{provider}?#{query.to_query}"
  end

  def logrocket_key(key)
    "<script>window.LogRocketKey = '#{key}';</script>".html_safe
  end

  def split_name(name)
    Util.split_name(name)
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
