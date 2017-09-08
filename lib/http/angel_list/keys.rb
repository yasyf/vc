module Http::AngelList::Keys
  def self.test_url(token)
    "https://api.angel.co/1/users/search?slug=phineasb&access_token=#{token}"
  end

  def self.test(token)
    HTTParty.get(test_url(token)).code == 200
  end

  def self.get(id, secret, code)
    HTTParty.post('https://angel.co/api/oauth/token', body: {
      client_id: id,
      client_secret: secret,
      code: code,
      grant_type: 'authorization_code'
    }).parsed_response['access_token']
  end
end
