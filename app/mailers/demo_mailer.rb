class DemoMailer < ExternalMailer
  default from: "VCWiz Demo <#{ENV['DEMO_EMAIL']}>"

  def demo_email(founder, target, subject, message_id)
    @founder = founder
    @target = target
    headers({'In-Reply-To': message_id, 'References': message_id})
    mail to: named_email(founder), cc: "VCWiz <#{ENV['MAILGUN_EMAIL']}>", subject: "RE: #{subject}"
  end
end
