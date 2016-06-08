module CompaniesHelper
  def company_class(company)
    if company.pitch_on.blank?
      ''
    elsif !company.pitched?
      'info'
    elsif company.funded?
      'success'
    else
      'danger'
    end
  end
end
