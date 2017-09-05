module Http::AngelList::Errors
  class APIError < StandardError
  end

  class RateLimited < APIError
  end
end
