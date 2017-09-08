class Entity < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :category, presence: true

  def self.from_html(body)
    text = ActionView::Base.full_sanitizer.sanitize(body).squish
    from_cloud GoogleCloud::Language.new(text).entities.proper
  rescue Google::Cloud::InvalidArgumentError
    []
  end

  def self.from_cloud(entities)
    entities.to_a.map do |e|
      where(name: e.name).first_or_create! do |entity|
        entity.category = e.type
        entity.wiki = e.metadata['wiki']
        entity.mid = e.metadata['mid']
      end
    end
  end
end
