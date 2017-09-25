module Concerns
  module Twitterable
    extend ActiveSupport::Concern

    included do
      attr_writer :twitter_opts

      def twitter_opts
        @twitter_opts || {}
      end
    end

    private

    def twitter_client
      @twitter_client ||= TwitterApi::Client.new(**twitter_opts)
    end
  end
end
