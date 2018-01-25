class FounderMailer < ExternalMailer
  layout 'intro_mailer'

  def bad_link_email(founder)
    @founder = founder
    mail to: named_email(founder), subject: "VCWiz Link Authorization Issue"
  end
end