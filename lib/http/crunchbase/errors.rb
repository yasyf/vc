module Http::Crunchbase::Errors
  class Error < StandardError
  end

  class BadRequest < Error
  end

  class APIError < Error
  end

  class Timeout < APIError
  end

  class RateLimited < APIError
  end
end
