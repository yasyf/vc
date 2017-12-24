module External::ApplicationHelper
  include ::ApplicationHelper

  def hash_to_options(h)
    h.map { |k, v| { value: k, label: v } }
  end

  def arr_to_options(a)
    a.map { |v| { value: v, label: v } }
  end

  def records_to_options(a, key = 'name')
    a.map { |v| v.merge({ value: v['id'], label: v[key] }) }
  end

  def flash_success(message)
    flash[:success] ||= []
    flash[:success] << message
  end

  def flash_failure(message)
    flash[:error] ||= []
    flash[:error] << message
  end

  def foundation_flash_type(level)
    case level.to_sym
      when :alert     then 'alert'
      when :success   then 'success'
      when :warning   then 'warning'
      when :info      then 'warning'
      when :error     then 'alert'
      when :alert     then 'alert'
      when :secondary then 'secondary'
      else 'success'
    end
  end

  def foundation_flashes(current_request: nil)
    (current_request || request).flash.flat_map do |level, messages|
      return nil if messages.blank?
      type = foundation_flash_type level
      Array.wrap(messages).map do |m|
        {type: type, message: m}
      end
    end.compact
  end
end
