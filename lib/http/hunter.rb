class Http::Hunter
  THRESHOLD = 90

  def initialize(person, company)
    @person = person
    @company = company
  end

  def social
    return nil unless find.present? && (data = find['data']).present?
    return nil unless data['email'].present?
    return nil unless data['score'] > THRESHOLD
    data.slice('email', 'position', 'twitter', 'linkedin')
  end

  private

  def url
    query = {
      domain: @company.domain,
      first_name: @person.first_name,
      last_name: @person.last_name,
      api_key: self.class.next_key,
    }
    "https://api.hunter.io/v2/email-finder?#{query.to_query}"
  end

  def find
    @found ||= begin
      body = Http::Fetch.get_one(url)
      JSON.parse(body) if body.present?
    end
  end

  def self.next_key
    ENV['HUNTER_API_KEYS'].split(',').sample
  end
end