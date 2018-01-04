module Http
  class TextProcessing
    include HTTParty
    base_uri 'http://text-processing.com/api'

    NEGATIVE = -0.5
    NEUTRAL = 0
    POSITIVE = 0.5

    def self.sentiment(body)
      text = Util.text_content(body)
      resp = self.post('/sentiment/', body: { text: text }).parsed_response
      return nil unless resp.present?
      probability = resp['probability']
      return nil unless probability.present?
      magnitude = probability[resp['label']]
      total = probability.values.sum
      score = NEGATIVE * (probability['neg'] / total) + NEUTRAL * (probability['neutral'] / total) + POSITIVE * (probability['pos'] / total)
      OpenStruct.new(magnitude: magnitude, score: score)
    end
  end
end
