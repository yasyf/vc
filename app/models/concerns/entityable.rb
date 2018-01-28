module Concerns
  module Entityable
    extend ActiveSupport::Concern
    include Concerns::Ignorable

    included do
      has_many :person_entities, as: :person, dependent: :destroy
      has_many :entities, through: :person_entities

      define_method(:scrape_tweets!) do
        return unless tweeter.present?
        return if tweeter.private?
        tweeter.latest_tweets.each do |tweet|
          add_entities! Entity.from_text(tweet.text)
        end
      rescue Twitter::Error::Unauthorized # private account
        tweeter.update! private: true
        nil
      end if reflect_on_association(:tweeter).present?
    end

    def add_entities!(entities, owner: nil)
      entities.each do |entity|
        ignore_unique { PersonEntity.where(person: owner || self, entity: entity).first_or_create! }
      end
    end
  end
end
