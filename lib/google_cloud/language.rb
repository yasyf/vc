require 'google/cloud/language'

module GoogleCloud
  class Sentiment
    NEUTRAL_MIN = -0.25
    NEUTRAL_MAX = 0.25
    MAGNITUDE_THRESHOLD = 0.2

    def initialize(sentiment)
      @sentiment = sentiment
    end

    def method_missing(m, *args, &block)
      @sentiment.send(m, *args, &block)
    end

    def negative?
      score < NEUTRAL_MIN && magnitude > MAGNITUDE_THRESHOLD
    end

    def neutral?
      magnitude <= MAGNITUDE_THRESHOLD || (NEUTRAL_MIN <= score <= NEUTRAL_MAX)
    end

    def positive?
      score > NEUTRAL_MAX && magnitude > MAGNITUDE_THRESHOLD
    end
  end

  class Entities
    def initialize(entities)
      @entities = entities
    end

    def to_a
      @entities
    end

    %i(common proper).each do |type|
      define_method(type) do
        Entities.new of_mention_type(type)
      end
    end

    def of_type(type)
      Entities.new(@entities.select {|e| e.type == type.upcase })
    end

    private

    def of_mention_type(type)
      @entities.select {|e| e.mentions.all? { |m| m.type == type.upcase } }
    end
  end

  class Language
    def initialize(text, format: :text)
      @document = self.class.client.document text, format: format
    end

    def sentiment
      Sentiment.new @document.sentiment
    end

    def entities
      Entities.new @document.entities
    end

    def self.client
      @client ||= ::Google::Cloud::Language.new project: ENV['GC_PROJECT_ID']
    end
  end
end
