class News < ApplicationRecord
  belongs_to :investor
  belongs_to :company

  validates :url, presence: true, uniqueness: { scope: [:investor, :company] }
  validates :title, presence: true
  validates :description, presence: true

  before_validation :set_meta!, on: :create

  attr_writer :body

  def as_json(options = {})
    super options.reverse_merge(only: [:id, :title, :url, :description, :published_at])
  end

  def body
    @body ||= Http::Fetch.get_one(url)
  end

  def page
    @page ||= MetaInspector.new(url, document: body)
  rescue MetaInspector::Error
    raise ActiveRecord::RecordInvalid.new(self)
  end

  def sentiment
    @sentiment ||= Http::TextProcessing.sentiment(body) if body.present?
  end

  def self.create_with_body(url, body, investor: nil, company: nil, attrs: {})
    where({ url: url, investor: investor, company: company }.compact).first_or_initialize.tap do |news|
      news.assign_attributes(attrs)
      news.body = body
      news.save!
    end
  end

  private

  def set_meta!
    self.title ||= page.best_title
    self.description ||= page.best_description
    self.sentiment_score ||= sentiment&.score
    self.sentiment_magnitude ||= sentiment&.magnitude

    self.title = CGI.unescapeHTML(self.title) if self.title.present?
  end
end
