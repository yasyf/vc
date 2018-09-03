class Internal::Api::V2::CompanyResource < JSONAPI::Resource
  attribute :name
  attribute :description
  attribute :industry
  attribute :crunchbase_id
  attribute :al_id

  has_one :team
  has_many :pitches
  has_many :partners, relation_name: 'users'
  has_many :founders

  filter :team
end
