class Model < ApplicationRecord

  validates :name, presence: true
  validates :version, presence: true

  def self.next(*components)
    name = components.join('.')
    if (existing = where(name: name).order(version: :desc).first).present?
      create! name: name, version: existing.version + 1
    else
      create! name: name, version: 0
    end
  end

  def self.storage
    @storage ||= GoogleCloud::Storage.new(ENV['GOOGLE_MODEL_BUCKET'])
  end

  def filename
    "#{name}-#{version}"
  end

  def slug
    name.parameterize
  end

  def data_path
    "data/#{slug}"
  end

  def model_path
    "model/#{slug}"
  end

  def upload_data!
    file = Tempfile.new(filename)
    Founder.export_rating_data(file.path)
    file.close
    cloud_file = self.class.storage.put(file.path, data_path)
    file.unlink
    update! data_generation: cloud_file.generation
  end

  def as_json(options = {})
    super options.reverse_merge(methods: [:data_path, :model_path])
  end

  def train!
    GoogleCloud::PubSub.new(ENV['GOOGLE_MODEL_TOPIC']).publish(as_json)
  end
end
