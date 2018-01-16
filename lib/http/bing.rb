class Http::Bing
  def self.url(service, q, mkt)
    "https://api.cognitive.microsoft.com/bing/v7.0/#{service}?q=#{ERB::Util.url_encode(q)}&mkt=#{mkt}"
  end

  def self.api_key
    ENV['MSFT_API_KEY'].split(',').sample
  end

  def self.fetch(service, q, mkt = 'en-us')
    body = Http::Fetch.get_advanced(self.url(service, q, mkt), {
      'Ocp-Apim-Subscription-Key': api_key
    })
    JSON.parse body
  rescue JSON::ParserError
    { 'value' => [] }
  end

  def self.news(q)
    fetch('news/search', q)['value']
  end
end