class Internal::Api::V2::CompanyResource < JSONAPI::Resource
  attributes :name, :description, :industry

  has_one :team
  has_many :pitches
  has_many :partners, relation_name: 'users'
  has_many :founders
end
