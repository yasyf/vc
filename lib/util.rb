class Util
 def self.log_exception(e)
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
 end

  def self.split_name(name)
    first, *rest = name.split(' ')
    [first, rest.join(' ')]
  end

 def self.escape_sql_argument(arg)
   arg.gsub(/\s(?![\&|\!|\|])/, '\\\\ ')
 end

  def self.fix_encoding(string, fallback_encoding = 'CP1252')
    begin
      clean_string(tidy_utf8(string))
    rescue ArgumentError, Encoding::UndefinedConversionError
      clean_string(string.encode(fallback_encoding, fallback: {
        "\u0081" => "\x81".force_encoding(fallback_encoding),
        "\u008D" => "\x8D".force_encoding(fallback_encoding),
        "\u008F" => "\x8F".force_encoding(fallback_encoding),
        "\u0090" => "\x90".force_encoding(fallback_encoding),
        "\u009D" => "\x9D".force_encoding(fallback_encoding),
      }).force_encoding('UTF-8'))
    end
  rescue ArgumentError, Encoding::UndefinedConversionError
    clean_string(string)
  end

  def self.tidy_utf8(string)
    clean_string(string.force_encoding('UTF-8').mb_chars.tidy_bytes)
  end

  def self.clean_string(string)
    string.gsub("\u0000", '').squish.to_s.encode('UTF-8',  invalid: :replace, undef: :replace, replace: '')
  end
end
