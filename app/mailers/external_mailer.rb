class ExternalMailer < ApplicationMailer
  default from: "VCWiz <#{ENV['MAILGUN_EMAIL']}>"
  after_action :set_mailgun_options!

  private

  def set_mailgun_options!
    mail.delivery_method.settings.merge!(
      address:              'smtp.mailgun.org',
      port:                 587,
      domain:               ENV['MAILGUN_EMAIL'].split('@').last,
      user_name:            mail.from.first,
      password:             ENV['MAILGUN_PASSWORD'],
      authentication:       'plain',
      enable_starttls_auto: true
    )
  end

  def named_email(person)
    "#{person.name} <#{person.email}>"
  end
end
