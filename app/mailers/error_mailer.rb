class ErrorMailer < ApplicationMailer
  def datetime_not_found_email(to, list_name, card_name, card_link)
    @list_name = list_name
    @card_name = card_name
    @card_link = card_link
    mail to: to, subject: "#{SUBJECT_HEADER} Invalid Trello Card Title"
  end
end
