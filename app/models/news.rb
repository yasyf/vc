class News < ApplicationRecord
  belongs_to :investor
  belongs_to :company

  validates :url, presence: true, uniqueness: { scope: [:investor, :company] }
  validates :title, presence: true
  validates :description, presence: true

  before_validation :set_meta!, on: :create

  attr_accessor :body

  def as_json(options = {})
    super options.reverse_merge(only: [:title, :url, :description, :published_at])
  end

  def page
    @page ||= begin
      if @body.present?
        MetaInspector.new(url, document: @body)
      else
        MetaInspector.new(url, download_images: false).tap do |page|
          raise ActiveRecord::RecordInvalid.new(self) unless page.response.status == 200
        end
      end
    end
  rescue MetaInspector::Error
    raise ActiveRecord::RecordInvalid.new(self)
  end

  def self.create_with_body(url, body, attrs = {})
    where(attrs.merge(url: url)).first_or_create!.tap do |news|
      news.body = body
    end
  end

  private

  def set_meta!
    self.title ||= page.best_title
    self.description ||= page.best_description

    self.title = CGI.unescapeHTML(self.title) if self.title.present?
  end
end
