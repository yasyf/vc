class Util
 def self.log_exception(e)
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
  end
end
