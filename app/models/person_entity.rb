class PersonEntity < ApplicationRecord
  belongs_to :entity, counter_cache: true
  belongs_to :person, polymorphic: true
end
