module Http
  class TextProcessing
    include HTTParty
    base_uri 'http://text-processing.com/api'

    NEGATIVE = -0.5
    NEUTRAL = 0
    POSITIVE = 0.5

    def self.sentiment(body)
      text = Readability::Document.new(body).content
      resp = self.post('/sentiment/', body: { text: text }).parsed_response
      probability = resp['probability']
      magnitude = probability[resp['label']]
      total = probability.values.sum
      score = NEGATIVE * (probability['neg'] / total) + NEUTRAL * (probability['neutral'] / total) + POSITIVE * (probability['pos'] / total)
      OpenStruct.new(magnitude: magnitude, score: score)
    end
  end
end
