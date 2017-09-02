class IntroMailer < ApplicationMailer
  helper :intro_mail

  def opt_in_email(request)
    set_instance_vars! request
    mail to: named_email(@investor), subject: "#{@company.name} <> #{@competitor.name}"
  end

  def request_email(request)
    set_instance_vars! request
    mail to: named_email(@investor), subject: "#{@company.name} <> #{@competitor.name}"
  end

  def intro_email(request)
    set_instance_vars! request
    mail to: [named_email(@investor), named_email(@founder)], subject: "#{@company.name} <> #{@competitor.name}"
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

  def named_email(person)
    "#{person.name} <#{person.email}>"
  end

  def set_instance_vars!(request)
    @request = request
    @investor = request.investor
    @company = request.company
    @founder = request.founder
    @competitor = @investor.competitor
  end
end
