class TwitterApi::Client
  def self.consumer_key(i)
    ENV['TWITTER_CONSUMER_KEY'].split(',')[i]
  end

  def self.consumer_secret(i)
    ENV['TWITTER_CONSUMER_SECRET'].split(',')[i]
  end

  def self.key_count
    ENV['TWITTER_CONSUMER_KEY'].split(',').count
  end

  def initialize(write: false)
    @needs_token = write
    @key_index = write ? 0 : rand(0...self.class.key_count)
  end

  def with_client(default = nil)
    yield client
  rescue Twitter::Error::NotFound
    default
  end

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = self.class.consumer_key(@key_index)
      config.consumer_secret = self.class.consumer_secret(@key_index)
      config.access_token = ENV['TWITTER_ACCESS_TOKEN'] if @needs_token
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET'] if @needs_token
    end
  end
end
