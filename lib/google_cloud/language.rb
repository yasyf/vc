require "google/cloud/language"

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

  class Language
    def initialize(text)
      @language = ::Google::Cloud::Language.new project: ENV['GC_PROJECT_ID']
      @document = @language.document text
    end

    def sentiment
      Sentiment.new @document.sentiment
    end
  end
end
