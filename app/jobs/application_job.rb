class ApplicationJob < ActiveJob::Base
  retry_on Net::OpenTimeout, wait: :exponentially_longer, attempts: 10
  retry_on Http::AngelList::Errors::RateLimited, wait: :exponentially_longer, queue: :low, attempts: 10
end
