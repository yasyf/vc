class News < ApplicationRecord
  belongs_to :investor
  belongs_to :company

  validates :url, presence: true, uniqueness: { scope: [:investor, :company] }
  validates :title, presence: true
  validates :description, presence: true

  before_validation :set_meta!, on: :create

  def page
    @page ||= MetaInspector.new(url, download_images: false)
  rescue MetaInspector::Error
    raise ActiveRecord::RecordInvalid.new(self)
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:title, :url, :description])
  end

  private

  def set_meta!
    raise ActiveRecord::RecordInvalid.new(self) unless page.response.status == 200
    self.title ||= page.best_title
    self.description ||= page.best_description
  end
end
