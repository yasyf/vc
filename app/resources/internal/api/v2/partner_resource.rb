class Internal::Api::V2::PartnerResource < JSONAPI::Resource
  attributes :username
  model_name 'User'

  def self.find_by_key(key, options = {})
    if key.nil?
      key = options[:context][:current_user].id
    end
    super(key, options)
  end
end
