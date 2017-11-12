class InternalMailer < ApplicationMailer
  SUBJECT_HEADER = '[DRFBot]'

  default from: "DRFBot <#{ENV['GMAIL_USERNAME']}>"

  def self.email_and_slack!(emailer, users, *args, cc_all: false)
    raise NoMethodError unless respond_to? emailer
    emails = Array.wrap(users).map do |u|
      u.is_a?(Team) ? "#{u.name.titleize} Team <#{u.email_list}>" : "#{u.name} <#{u.email}>"
    end
    mail = public_send(emailer, emails, *args)
    mail.cc = ENV['ALL_TEAMS_MAILING_LIST'] if cc_all
    mail.deliver_now
    text = mail.text_part.body.decoded
    Array.wrap(users).each do |u|
      u.is_a?(Team) ? u.notify!(text) : u.send!(text)
    end
  end
end
