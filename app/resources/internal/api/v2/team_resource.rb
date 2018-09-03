class Internal::Api::V2::TeamResource < JSONAPI::Resource
  attribute :name

  has_many :partners
end
