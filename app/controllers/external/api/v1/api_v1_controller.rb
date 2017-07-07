class External::Api::V1::ApiV1Controller < External::ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
end
