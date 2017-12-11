class SummaryMailer < ExternalMailer
  layout 'summary_mailer'

  def welcome_founder_email(founder)
    @founder = founder
    mail to: named_email(founder), subject: "Welcome to VCWiz #{@founder.first_name}!"
  end

  def weekly_founder_email(founder)
    @founder = founder
    @stats = founder.stats(Email.where('emails.created_at >= ?', 1.week.ago))
    @events = founder.events(Event.where('events.created_at >= ?', 1.week.ago)).includes(subject: :investor).sample(5)
    @requests = founder.intro_requests.where('intro_requests.created_at >= ?', 1.week.ago).count
    mail to: named_email(founder), subject: "Weekly VCWiz Summary For #{founder.primary_company.name}", reply_to: ENV['SUPPORT_EMAIL']
  end
end
