module GoogleApi
  class Base
    SCOPES = []

    private

    def authorization
      @authorization ||= Google::Auth.get_application_default(self.class::SCOPES).tap do |auth|
        auth.update! sub: "#{ENV['ADMIN']}@#{ENV['domain']}"
      end
    end
  end
end
