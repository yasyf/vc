class ApplicationMailer < ActionMailer::Base
  SUBJECT_HEADER = '[DRFBot]'

  default from: ENV['GMAIL_USERNAME']
  layout 'mailer'

  def self.email_and_slack!(emailer, users, *args, cc_all: false)
    raise NoMethodError unless respond_to? emailer
    if users.is_a?(Team)
      mail = public_send(emailer, users.email_list, *args)
      mail.cc = ENV['ALL_TEAMS_MAILING_LIST'] if cc_all?
      mail.deliver_now
      users.notify! mail.text_part.body.decoded
    else
      users = Array.wrap(users)
      mail = public_send(emailer, users.map(&:email), *args)
      mail.cc = ENV['ALL_TEAMS_MAILING_LIST'] if cc_all?
      mail.deliver_now
      users.each { |user| user.send! mail.text_part.body.decoded }
    end
  end
end
