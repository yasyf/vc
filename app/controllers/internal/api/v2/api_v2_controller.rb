class Internal::Api::V2::ApiV2Controller < JSONAPI::ResourceController
  def context
    {current_user: current_internal_user}
  end
end
