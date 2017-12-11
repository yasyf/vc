class IntroMailer < ExternalMailer
  layout 'intro_mailer'
  helper :intro_mail
  after_action :add_headers!

  def opt_in_email(request)
    set_instance_vars! request
    @email = request.email!
    mail to: investor_email, subject: "#{@company.name} <> #{@competitor.name}"
  end

  def request_email(request)
    set_instance_vars! request
    @email = request.email!
    mail to: investor_email, subject: "#{@company.name} <> #{@competitor.name}"
  end

  def request_preview_email(request)
    set_instance_vars! request
    mail to: investor_email, subject: "#{@company.name} <> #{@competitor.name}"
  end

  def intro_email(request)
    set_instance_vars! request
    @email = request.email!
    mail to: [investor_email, founder_email], subject: "#{@company.name} <> #{@competitor.name}"
  end

  def reason_email(request)
    set_instance_vars! request
    mail to: investor_email, subject: "Re: #{@company.name} <> #{@competitor.name}"
  end

  def no_opt_in_email(request)
    set_instance_vars! request
    mail to: founder_email, subject: "Introduction to #{@investor.name} (#{@competitor.name})"
  end

  def no_intro_email(request)
    set_instance_vars! request
    mail to: founder_email, subject: "Introduction to #{@investor.name} (#{@competitor.name})"
  end

  private

  def founder_email
    named_email(@founder)
  end

  def investor_email
    @target&.email.present? ? named_email(@target) : named_email(@investor)
  end

  def add_headers!
    vars = { intro_request_token: @request.public_token }
    mail.headers({
      'X-Mailgun-Recipient-Variables': Array.wrap(mail.to).map { |to| [to, vars] }.to_h.to_json,
      'X-Mailgun-Variables': vars.to_json,
    })
  end

  def set_instance_vars!(request)
    @request = request
    @investor = request.investor
    @company = request.company
    @founder = request.founder
    @target = request.target_investor
    @competitor = @investor.competitor
  end
end
