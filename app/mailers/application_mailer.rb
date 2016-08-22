class ApplicationMailer < ActionMailer::Base
  extend Concerns::Slackable

  SUBJECT_HEADER = '[Boston Bot]'

  default from: ENV['GMAIL_USERNAME']
  layout 'mailer'

  def self.email_and_slack!(emailer, users, *args)
    raise NoMethodError unless respond_to? emailer
    if user.is_a?(Team)
      mail = public_send(emailer, user.email_list, *args)
      mail.deliver_later
      slack_send! user.slack_channel, mail.text_part.body.decoded, notify: true
    else
      users = Array.wrap(users)
      mail = public_send(emailer, users.map(&:email), *args)
      mail.deliver_later
      users.each { |user| user.send! mail.text_part.body.decoded }
    end
  end
end
