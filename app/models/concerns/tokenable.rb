module Concerns
  module Tokenable
    extend ActiveSupport::Concern

    included do
      validates :token, presence: true
      before_validation :set_token!, on: :create
    end

    private

    def set_token!
      self.token ||= Util.token
    end
  end
end
