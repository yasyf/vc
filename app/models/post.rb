class Post < ApplicationRecord
  belongs_to :investor
  has_many :person_entities, as: :person
  has_many :entities, through: :person_entities

  validates :url, presence: true
  validates :title, presence: true
  validates :published_at, presence: true

  def categories
    Entity
      .where(id: person_entities.references(:entities).where(featured: true).select('entity_id'))
      .order(person_entities_count: :desc)
      .limit(3)
  end

  def as_json(options = {})
    super options.reverse_merge(
      only: [:url, :title, :published_at],
      methods: [:categories]
    )
  end
end
