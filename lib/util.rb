class Util
 def self.log_exception(e)
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
 end

  def self.split_name(name)
    first, *rest = name.split(' ')
    [first, rest.join(' ')]
  end

  def self.fix_encoding(string, encoding = 'CP1252')
    string.encode(encoding, fallback: {
      "\u0081" => "\x81".force_encoding(encoding),
      "\u008D" => "\x8D".force_encoding(encoding),
      "\u008F" => "\x8F".force_encoding(encoding),
      "\u0090" => "\x90".force_encoding(encoding),
      "\u009D" => "\x9D".force_encoding(encoding),
    }).force_encoding('UTF-8').gsub("\u0000", '').squish
  end
end
