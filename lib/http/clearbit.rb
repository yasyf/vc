class Http::Clearbit
  class Error < StandardError
  end

  def initialize(person, company)
    @person = person
    @company = company
  end

  def enhance
    @enhanced ||= Clearbit::Enrichment.find(email: @person.email,
                                            given_name: @person.first_name,
                                            family_name: @person.last_name,
                                            ip_address: @person.try(:ip_address),
                                            location: @person.try(:location) || @person.try(:city),
                                            company: @company.try(:name),
                                            company_domain: @company.try(:domain),
                                            linkedin: @person.linkedin,
                                            twitter: @person.twitter,
                                            facebook: @person.facebook,
                                            stream: true)
  rescue Exception => e
    raise Error.new(e)
  end
end
