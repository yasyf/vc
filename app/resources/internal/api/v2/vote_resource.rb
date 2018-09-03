class Internal::Api::V2::VoteResource < JSONAPI::Resource
  attribute :fit
  attribute :team
  attribute :product
  attribute :market
  attribute :overall
  attribute :reason
  attribute :final

  has_one :partner, relation_name: 'user', foreign_key: 'user_id'
  has_one :pitch
end
