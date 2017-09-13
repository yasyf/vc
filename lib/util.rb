class Util
 def self.log_exception(e)
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
 end

  def self.split_name(name)
    first, *rest = name.split(' ')
    [first, rest.join(' ')]
  end
end
