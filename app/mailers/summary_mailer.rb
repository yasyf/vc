class SummaryMailer < ExternalMailer
  layout 'intro_mailer'

  def weekly_founder_email(founder)
    @founder = founder
    @stats = founder.stats(Email.where('emails.created_at >= ?', 1.week.ago))
    @events = founder.events(Event.where('events.created_at >= ?', 1.week.ago)).includes(subject: :investor)
    mail to: named_email(founder), subject: "Weekly VCWiz Summary For #{founder.primary_company.name}"
  end
end
