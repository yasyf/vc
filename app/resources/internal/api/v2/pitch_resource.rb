class Internal::Api::V2::PitchResource < JSONAPI::Resource
  attribute :when
  attribute :decision
  attribute :deadline
  attribute :snapshot

  has_one :company
  has_many :votes
end
