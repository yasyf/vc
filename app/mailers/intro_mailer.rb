class IntroMailer < ExternalMailer
  helper :intro_mail
  after_action :add_headers!

  def opt_in_email(request)
    set_instance_vars! request
    mail to: named_email(@investor), subject: "#{@company.name} <> #{@competitor.name}"
  end

  def request_email(request)
    set_instance_vars! request
    mail to: named_email(@investor), subject: "#{@company.name} <> #{@competitor.name}"
  end

  def request_preview_email(request)
    set_instance_vars! request
    mail to: named_email(@investor), subject: "#{@company.name} <> #{@competitor.name}"
  end

  def intro_email(request)
    set_instance_vars! request
    mail to: [named_email(@investor), named_email(@founder)], subject: "#{@company.name} <> #{@competitor.name}"
  end

  def reason_email(request)
    set_instance_vars! request
    mail to: named_email(@investor), subject: "Re: #{@company.name} <> #{@competitor.name}"
  end

  def no_opt_in_email(request)
    set_instance_vars! request
    mail to: named_email(@founder), subject: "Introduction to #{@investor.name} (#{@competitor.name})"
  end

  def no_intro_email(request)
    set_instance_vars! request
    mail to: named_email(@founder), subject: "Introduction to #{@investor.name} (#{@competitor.name})"
  end

  private

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
    @competitor = @investor.competitor
  end
end
