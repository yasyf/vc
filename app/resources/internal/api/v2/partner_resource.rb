class Internal::Api::V2::PartnerResource < JSONAPI::Resource
  attribute :username
  model_name 'User'

  has_many :companies
  has_many :votes

  def self.find_by_key(key, options = {})
    if key.nil?
      key = options[:context][:current_user].id
    end
    super(key, options)
  end
end
