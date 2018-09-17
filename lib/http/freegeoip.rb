class Http::Freegeoip
  def initialize(ip)
    @ip = ip
  end

  def locate
    @located ||= JSON.parse(Http::Fetch.get_one("http://api.ipstack.com/json/#{@ip}?access_key=#{ENV['IPSTACK_KEY']}"))
  end
end
