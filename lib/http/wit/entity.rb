module Http::Wit
  class Entity
    include HTTParty
    base_uri 'https://api.wit.ai/entities'
    format :json
    headers Authorization: "Bearer #{ENV['WIT_API_TOKEN']}", 'Content-Type': 'application/json'
    default_params v: ENV['WIT_API_VERSION']

    def initialize(entity)
      @entity = entity
    end

    def values
      self.class.get("/#{@entity}").parsed_response["values"]
    end

    def add_value(value)
      self.class.post("/#{@entity}/values", body: { value: value, expressions: [value] }.to_json).parsed_response
    end
  end
end
