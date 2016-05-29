class LoggedError < ActiveRecord::Base


  validates :reason, presence: true, uniqueness: { scope: [:record_id] }
  validates :count, presence: true

  def self.log!(reason, record, to, *args, notify: 1)
    log = first_or_create!(record_id: record.id, reason: reason)
    log.increment! :count
    unless log.count > notify
      emailer = "#{reason}_email"
      users = parse_to(to)
      ErrorMailer.email_and_slack! emailer, users, *args
    end
  end

  private

  def self.parse_to(to)
    Array.wrap(to).map do |item|
      next if item.is_a?(User)
      User.find(item) if item.is_a?(Integer)
      User.where(username: item).first if item.is_a?(String)
    end.compact
  end
end
