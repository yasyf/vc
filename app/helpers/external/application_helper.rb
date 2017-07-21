module External::ApplicationHelper
  include ::ApplicationHelper

  def hash_to_options(h)
    h.map { |k, v| { value: k, label: v } }
  end

  def login_stages
    %w(start company profile suggest done).each_with_index.flat_map do |s, i|
      [[s, i], [i, i]]
    end.to_h
  end

  def foundation_flash_type(level)
    case level.to_sym
      when :alert     then 'alert'
      when :success   then 'success'
      when :info      then 'warning'
      when :error     then 'alert'
      when :secondary then 'secondary'
      else 'success'
    end
  end

  def foundation_flashes
    flash.flat_map do |level, messages|
      return nil if messages.blank?
      type = foundation_flash_type level
      Array.wrap(messages).map do |m|
        [type, m]
      end
    end.compact
  end
end
