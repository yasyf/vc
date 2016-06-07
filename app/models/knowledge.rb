class Knowledge < ActiveRecord::Base
  belongs_to :user

  validates :body, presence: true
  validates :ts, presence: true, uniqueness: true

  def decoded
    Slack::Messages::Formatting.unescape body
  end
end
