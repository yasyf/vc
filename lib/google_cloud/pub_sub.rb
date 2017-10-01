require 'google/cloud/pubsub'

module GoogleCloud
  class PubSub
    def initialize(topic)
      @topic = self.class.client.topic topic
    end

    def publish(message)
      @topic.publish message.to_json
    end

    def self.client
      @client ||= ::Google::Cloud::Pubsub.new project: ENV['GC_PROJECT_ID']
    end
  end
end
