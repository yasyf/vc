module IntroMailHelper
  VOWELS = %w(a e i o u)

  def founder(founder)
    link = Founder::SOCIAL_KEYS.find { |k| founder.send(k).present? }
    return founder.name unless link.present?
    prefix = case link
      when :linkedin
        'https://www.linkedin.com/in/'
      when :facebook
        'https://fb.com/'
      when :twitter
        'https://twitter.com/'
      else
        ''
    end
    "<a href='#{prefix}#{founder.send(link)}'>#{founder.name}</a>"
  end

  def role(investor)
    return 'an investor' unless investor.role.present?
    investor.role.start_with?(*VOWELS) ? "an #{investor.role}" : "a #{investor.role}"
  end

  def company(company)
    return company.name unless company.domain.present?
    "<a href='http://#{company.domain}'>#{company.name}</a>".html_safe
  end
end
