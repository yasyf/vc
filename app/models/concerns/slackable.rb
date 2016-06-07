module Concerns
  module Slackable
    extend ActiveSupport::Concern

    private

    def slack_send!(channel, message, notify: false)
      message = "<!channel> #{message}" if notify
      slack_client.chat_postMessage(channel: channel, text: message, as_user: true)
    end

    def slack_client
      @slack_client ||= Slack::Web::Client.new
    end

    class_methods do
      def slack_client_factory
        Slack::Web::Client.new
      end
    end
  end
end
