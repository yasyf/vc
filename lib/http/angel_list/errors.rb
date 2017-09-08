module Http::AngelList::Errors
  class APIError < StandardError
  end

  class Timeout < StandardError
  end

  class RateLimited < APIError
  end
end
