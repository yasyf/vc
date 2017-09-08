class PersonEntity < ApplicationRecord
  belongs_to :entity
  belongs_to :person, polymorphic: true
end
