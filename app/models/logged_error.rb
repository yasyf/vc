class LoggedError < ActiveRecord::Base
  validates :reason, presence: true, uniqueness: { scope: [:record_id] }
  validates :count, presence: true

  def self.log!(reason, record, *args, notify: 1)
    emailer = "#{reason}_email"
    raise NoMethodError unless ErrorMailer.respond_to? emailer
    log = first_or_create!(record_id: record.id, reason: reason)
    log.increment! :count
    ErrorMailer.public_send(emailer, *args).deliver_later unless log.count > notify
  end
end
