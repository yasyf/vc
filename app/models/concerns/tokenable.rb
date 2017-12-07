module Concerns
  module Tokenable
    extend ActiveSupport::Concern

    included do
      validates :token, presence: true
      before_validation :set_token!, on: :create
    end

    private

    def set_token!
      self.token ||= SecureRandom.hex.first(10).upcase
    end
  end
end
