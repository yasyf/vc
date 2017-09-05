module IntroMailHelper
  VOWELS = %w(a e i o u)

  def role(investor)
    return 'an investor' unless investor.role.present?
    investor.role.start_with?(*VOWELS) ? "an #{investor.role}" : "a #{investor.role}"
  end

  def company(company)
    return company.name unless company.domain.present?
    "<a href='http://#{company.domain}'>#{company.name}</a>".html_safe
  end
end
