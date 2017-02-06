module Concerns
  module Twitterable
    extend ActiveSupport::Concern

    private

    def twitter_client
      @twitter_client ||= TwitterApi::Client.new
    end
  end
end
