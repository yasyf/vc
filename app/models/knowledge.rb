class Knowledge < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :team, presence: true
  validates :body, presence: true
  validates :ts, presence: true, uniqueness: true

  def decoded
    Slack::Messages::Formatting.unescape body
  end
end
