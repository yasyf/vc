class BulkMailer < ExternalMailer
  layout false

  def nps_survey_email(founder, survey_id, subject, query)
    @founder = founder
    @url = "https://#{ENV['TYPEFORM_ACCOUNT']}.typeform.com/to/#{survey_id}?#{query.to_query}"
    @survey_id = survey_id
    mail to: named_email(founder), subject: subject
  end
end
