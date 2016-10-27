module CompaniesHelper
  def company_class(company)
    if company.funded?
      'success'
    elsif company.pitch_on.blank?
      'muted'
    elsif !company.pitched?
      'info'
    elsif !company.past_deadline?
      'warning'
    else
      'danger'
    end
  end
end
