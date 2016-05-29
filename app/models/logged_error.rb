class LoggedError < ActiveRecord::Base
  include Concerns::Slackable

  validates :reason, presence: true, uniqueness: { scope: [:record_id] }
  validates :count, presence: true

  def self.log!(reason, record, to, *args, notify: 1)
    log = first_or_create!(record_id: record.id, reason: reason)
    log.increment! :count
    unless log.count > notify
      emailer = "#{reason}_email"
      return unless ErrorMailer.respond_to? emailer
      users = parse_to(to)
      if users.present?
        mail = ErrorMailer.public_send(emailer, users.map(&:email), *args)
        mail.deliver_later
        users.each { |user| user.send! mail.text_part.body.decoded }
      else
        mail = ErrorMailer.public_send(emailer, ENV['LIST_EMAIL'], *args)
        mail.deliver_later
        slack_send! ENV['SLACK_CHANNEL'], message, notify: true
      end
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
