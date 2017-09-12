class Http::Freegeoip
  def initialize(ip)
    @ip = ip
  end

  def locate
    @located ||= JSON.parse(Http::Fetch.get_one("http://freegeoip.net/json/#{@ip}"))
  end
end