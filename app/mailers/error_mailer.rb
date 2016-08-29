class ErrorMailer < ApplicationMailer
  def datetime_not_found_email(to, list_name, card_name, card_link)
    @list_name = list_name
    @card_name = card_name
    @card_link = card_link
    mail to: to, subject: "#{SUBJECT_HEADER} Invalid Trello Card Title"
  end

  def invalid_company_data_email(to, company_json, error_message, trello_url, list_name)
    @company_json = company_json
    @error_message = error_message
    @trello_url = trello_url
    @list_name = list_name
    mail to: to, subject: "#{SUBJECT_HEADER} Invalid Trello Data For #{company_json['name']}"
  end
end
