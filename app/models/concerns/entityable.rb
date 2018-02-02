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
        tweeter.latest_tweets.unseen.each do |tweet|
          tweet.mark_as_seen!
          add_entities! Entity.from_text(tweet.text), bump_counts: true
        end
      rescue Twitter::Error::Unauthorized # private account
        tweeter.update! private: true
        nil
      end if reflect_on_association(:tweeter).present?
    end

    def add_entities!(entities, owner: nil, bump_counts: false)
      entities.each do |entity|
        scope = PersonEntity.where(person: owner || self, entity: entity)
        begin
          scope.first_or_create!
        rescue *unique_errors
          (record = scope.first!).with_lock do
            record.increment! :count
          end if bump_counts
        end
      end
    end
  end
end
