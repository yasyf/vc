module Concerns
  module Twitterable
    extend ActiveSupport::Concern

    included do
      @twitter_opts = {}
    end


    class_methods do
      def twitter(opts)
        @twitter_opts.merge!(opts)
        @twitter_client = nil
      end
    end

    private

    def twitter_client
      @twitter_client ||= TwitterApi::Client.new(**@twitter_opts)
    end
  end
end
