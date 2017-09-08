module Http::Crunchbase::Errors
  class APIError < StandardError
  end

  class RateLimited < APIError
  end
end
