module Http::AngelList::Errors
  class Error < StandardError
  end

  class APIError < Error
  end

  class Timeout < APIError
  end

  class RateLimited < APIError
  end
end
