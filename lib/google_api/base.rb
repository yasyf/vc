module GoogleApi
  class Base
    SCOPES = []

    private

    def authorization
      @authorization ||= Google::Auth.get_application_default(self.class::SCOPES).tap do |auth|
        auth.update! sub: "#{ENV['ADMIN']}@#{ENV['DOMAIN']}"
      end
    end
  end
end
