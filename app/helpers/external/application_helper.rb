module External::ApplicationHelper
  include ::ApplicationHelper

  def hash_to_options(h)
    h.map { |k, v| { value: k, label: v } }
  end
end
