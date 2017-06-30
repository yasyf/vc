module Internal::ApplicationHelper
  def title(title)
    content_for :title, title
  end

  def header(header)
    content_for :header, header
  end
end
