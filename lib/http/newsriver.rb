class Http::Newsriver
  def self.url(query)
    query = "text:(#{query}) AND language:en"
    "https://api.newsriver.io/v2/search?query=#{CGI.escape(query)}&sortBy=_score"
  end

  def self.api_key
    ENV['NEWSRIVER_API_KEY'].split(',').sample
  end

  def self.news(*queries)
    body = Http::Fetch.get_advanced(self.url(queries.map { |q| "\"#{q}\"" }.join(' AND ')), {
      'Authorization': api_key
    })
    JSON.parse body
  rescue HTTP::Fetch::Error
    []
  end
end
