class Internal::Api::V2::FounderResource < JSONAPI::Resource
  attribute :first_name
  attribute :last_name
  attribute :email

  has_many :companies
end
