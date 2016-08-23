module Http
  class Rdv
    include HTTParty
    base_uri 'roughdraft.vc'

    def investments
      @investments ||= Set.new self.class.get("/investments").parsed_response.scan(/<h4>([\w\s]+)<\/h4>/).flatten.map(&:downcase)
    end

    def invested?(company)
      investments.include? company.downcase
    end
  end
end
