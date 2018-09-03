class Internal::Api::V2::TeamResource < JSONAPI::Resource
  attributes :name

  has_many :partners
end
