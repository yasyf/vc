module ApplicationHelper
  def title(title)
    content_for :title, title
  end

  def omniauth_path(provider)
    "/auth/#{provider}"
  end

  def logrocket_key(key)
    "<script>window.LogRocketKey = '#{key}';</script>".html_safe
  end

  def split_name(name)
    first, *rest = name.split(' ')
    [first, rest.join(' ')]
  end
end
