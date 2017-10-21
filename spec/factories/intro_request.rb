FactoryBot.define do
  factory :intro_request do
    association :founder, :with_companies
    company { founder.primary_company }
    investor
  end
end