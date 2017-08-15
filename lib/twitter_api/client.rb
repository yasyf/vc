class TwitterApi::Client
  def with_client(default = nil)
    with_retries(max_retries: 3, rescue: Twitter::Error::TooManyRequests) do
      yield client
    end
  rescue Twitter::Error::NotFound, Twitter::Error::TooManyRequests, Twitter::Error::Unauthorized
    default
  end

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end
end
