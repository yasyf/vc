class InvestorMailer < ExternalMailer
  layout 'intro_mailer'

  def signup_email(investor, email)
    @investor = investor
    @email = email
    mail to: "#{investor.name} <#{email}>", subject: "VCWiz Investor Portal (#{investor.competitor.name})"
  end

  def invite_email(investor_id, inviter_id)
    @investor = Investor.find(investor_id)
    @inviter = Investor.find(inviter_id)
    mail to: named_email(@investor), subject: "Invite from #{@inviter.first_name}: VCWiz Investor Portal (#{@investor.competitor.name})"
  end
end