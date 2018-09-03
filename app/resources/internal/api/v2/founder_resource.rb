class Internal::Api::V2::FounderResource < JSONAPI::Resource
  attributes :first_name, :last_name, :email

  has_many :companies
end
