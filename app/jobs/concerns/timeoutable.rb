module Concerns
  module Timeoutable
    extend ActiveSupport::Concern

    def perform(*args)
      Timeout::timeout(10.minutes.to_i) do
        perform_with_timeout(*args)
      end
    end
  end
end
