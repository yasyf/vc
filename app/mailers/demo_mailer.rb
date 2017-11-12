class DemoMailer < ExternalMailer
  default from: "VCWiz Demo <#{ENV['DEMO_EMAIL']}>"

  def demo_email(founder, target, subject)
    @founder = founder
    @target = target
    mail to: named_email(founder), cc: "VCWiz <#{ENV['MAILGUN_EMAIL']}>", subject: "RE: #{subject}"
  end
end
