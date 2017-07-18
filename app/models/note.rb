class Note < ApplicationRecord
  belongs_to :founder
  belongs_to :subject, polymorphic: true

  validates :body, presence: true

  def as_json(options = {})
    options.reverse_merge!(only: [:id, :body], methods: [:founder])
    super(options)
  end
end
