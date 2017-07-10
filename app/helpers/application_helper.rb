module ApplicationHelper
  def title(title)
    content_for :title, title
  end

  def omniauth_path(provider)
    "/auth/#{provider}"
  end
end
