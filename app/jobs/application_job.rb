class ApplicationJob < ActiveJob::Base
  retry_on Net::OpenTimeout, wait: :exponentially_longer, attempts: 10
  retry_on Http::AngelList::Errors::RateLimited, wait: :exponentially_longer, queue: :low, attempts: 10
  retry_on Http::AngelList::Errors::Timeout, wait: :exponentially_longer, queue: :low, attempts: 10
  retry_on Http::Crunchbase::Errors::RateLimited, wait: :exponentially_longer, queue: :low, attempts: 10
  retry_on Http::Crunchbase::Errors::Timeout, wait: :exponentially_longer, queue: :low, attempts: 10
  retry_on Net::OpenTimeout, wait: :exponentially_longer, queue: :low, attempts: 10
  discard_on ActiveRecord::RecordNotFound
end
