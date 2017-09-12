class Entity < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { minimum: 3 }
  validates :category, presence: true

  def self.normalize(name)
    name.gsub(/\W/, ' ').squish.strip
  end

  def self.from_name(raw_name)
    return nil if (name = normalize(raw_name)).length < 3
    where(name: name).first_or_create!(category: 'OTHER')
  end

  def self.from_html(body)
    from_cloud GoogleCloud::Language.new(body, format: :html).entities.proper
  rescue Google::Cloud::InvalidArgumentError
    []
  end

  def self.from_cloud(entities)
    entities.to_a.map do |e|
      next unless e.metadata.present?
      next if (name = normalize(e.name)).length < 3
      where(name: name).first_or_create! do |entity|
        entity.category = e.type
        entity.wiki = e.metadata['wiki']
        entity.mid = e.metadata['mid']
      end
    end.compact
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:name, :wiki])
  end
end
