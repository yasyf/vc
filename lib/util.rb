class Util
  BAD_STRINGS = {
    'â€”' => '–',
    'â€“' => '—',
    'â€¢' => '-',
    'â€¦' => '…',
    'â€™' => "'",
    'â€˜' => "'",
    'â€œ' => '"',
    'â€' => '"',
  }

  def self.log_exception(e)
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
  end

  def self.split_name(name)
    first, *last = name.split(' ')
    [first, last.join(' ')]
  end

  def self.escape_sql_argument(arg)
    arg.gsub(/\s(?![\&|\!|\|])/, '\\\\ ')
  end

  def self.sanitize_sql(*args)
    ActiveRecord::Base.send(:sanitize_sql, args)
  end

  def self.fix_encoding(string, fallback_encoding = 'CP1252')
    return nil if string.nil?
    begin
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
    end.tap do |s|
      BAD_STRINGS.each { |bad, good| s.gsub!(bad, good) }
    end
  end

  def self.tidy_utf8(string)
    clean_string(string.force_encoding('UTF-8').mb_chars.tidy_bytes)
  end

  def self.clean_string(string)
    string.gsub("\u0000", '').squish.to_s.encode('UTF-8',  invalid: :replace, undef: :replace, replace: '')
  end

  def self.normalize_city(city)
    if city.in?(['New York', 'New York City', 'Brooklyn'])
      'New York'
    elsif city.in?(['San Francisco', 'SF Bay Area', 'Mountain View', 'Palo Alto', 'Menlo Park', 'South San Francisco', 'San Francisco Bay Area', 'Oakland', 'Stanford', 'Berkeley'])
      'San Francisco'
    elsif city.in?(['Washington, DC', 'Washington DC', 'Washington'])
      'Washington, DC'
    elsif city.in?(['Miami', 'Miami Beach', 'Miami Springs'])
      'Miami'
    elsif city.in?(['Chicago', 'Chicago Heights', 'Chicago Park'])
      'Chicago'
    else
      city
    end
  end

  def self.hub_city(session, founder)
   [
     founder&.primary_company&.location,
     founder&.city,
     session[:city],
   ].compact.map { |x| normalize_city(x) }.find { |x| Competitor.hub?x }
  end

  def self.ip_address(env)
    env['HTTP_X_FORWARDED_FOR'].try(:split, ',').try(:first) || env['REMOTE_ADDR']
  end

  def self.geo_search_ip(ip)
    Geocoder.search(ip)
  rescue Geocoder::LookupTimeout
    Geocoder.search(ip, ip_lookup: :geoip2)
  end

  def self.city(request)
    normalize_city geo_search_ip(ip_address(request.env)).first&.city
  end

  def self.split_slice(str, const)
    const.slice(*str.split(','))
  end

  def self.parse_domain(url)
    parsed = begin
      URI.parse(url).host
    rescue URI::InvalidURIError => _
    end || url

    parsed = parsed[4..-1] if parsed&.starts_with?('www.')
    parsed = parsed.split('@').last if parsed.present?
    parsed
  end

  def self.average_response_time(emails, grouper)
    average = Average.new
    emails.distinct.pluck(grouper).each do |group_id|
      scope = emails.where(grouper => group_id).order(created_at: :asc)
      outgoing = scope.outgoing.first
      while outgoing.present? && (incoming = scope.after(outgoing).incoming.first).present? do
        delta = incoming.created_at - outgoing.created_at
        average.add(delta)
        outgoing = scope.outgoing.after(incoming).first
      end
    end
    (average.to_f / 1.minute).minutes
  end

  def self.html_person(person, only_first: false)
    name = only_first ? person.first_name : person.name
    link = Founder::SOCIAL_KEYS.find { |k| person.send(k).present? }
    return name unless link.present?
    prefix = case link.to_sym
     when :linkedin
       'https://www.linkedin.com/in/'
     when :facebook
       'https://fb.com/'
     when :twitter
       'https://twitter.com/'
     else
       ''
    end
    "<a href='#{prefix}#{person.send(link)}'>#{name}</a>"
  end

  def self.count_lines(filename)
    `wc -l "#{filename}"`.strip.split(' ')[0].to_i
  end

  def self.token
    SecureRandom.hex.first(10).upcase
  end

  def self.truncated_description(record)
    (record.description || '').squish.truncate(150)
  end

  def self.text_content(html)
    Readability::Document.new(html).content
  rescue NoMethodError, ArgumentError
    html
  end
end
