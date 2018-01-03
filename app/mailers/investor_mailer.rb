class InvestorMailer < ExternalMailer
  layout 'intro_mailer'

  def signup_email(investor, email)
    @investor = investor
    @email = email
    mail to: "#{investor.name} <#{email}>", subject: "VCWiz Investor Portal (#{investor.competitor.name})"
  end

  def invite_email(investor, inviter)
    @inviter = inviter
    @investor = investor
    mail to: named_email(investor), subject: "Invite from #{inviter.first_name}: VCWiz Investor Portal (#{investor.competitor.name})"
  end
end