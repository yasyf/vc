class ApplicationMailer < ActionMailer::Base
  include Concerns::Slackable

  default from: ENV['GMAIL_USERNAME']
  layout 'mailer'

  def self.email_and_slack!(emailer, users, *args)
    raise NoMethodError unless respond_to? emailer
    if users.present?
      mail = public_send(emailer, users.map(&:email), *args)
      mail.deliver_later
      users.each { |user| user.send! mail.text_part.body.decoded }
    else
      mail = public_send(emailer, ENV['LIST_EMAIL'], *args)
      mail.deliver_later
      slack_send! ENV['SLACK_CHANNEL'], mail.text_part.body.decoded, notify: true
    end
  end
end
