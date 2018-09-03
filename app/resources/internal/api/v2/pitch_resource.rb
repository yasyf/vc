class Internal::Api::V2::PitchResource < JSONAPI::Resource
  attributes :when, :decision, :deadline, :snapshot

  has_one :company
  has_many :votes
end
