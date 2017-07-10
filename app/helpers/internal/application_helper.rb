module Internal::ApplicationHelper
  include ::ApplicationHelper

  def header(header)
    content_for :header, header
  end
end
