module Http::Crunchbase::Errors
  class APIError < StandardError
  end

  class Timeout < APIError
  end

  class RateLimited < APIError
  end
end
