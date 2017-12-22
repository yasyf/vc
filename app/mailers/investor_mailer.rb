class InvestorMailer < ExternalMailer
  layout 'intro_mailer'

  def signup_email(investor, email)
    @investor = investor
    @email = email
    mail to: "#{investor.name} <#{email}>", subject: "VCWiz Investor Portal (#{investor.competitor.name})"
  end
end