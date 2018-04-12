FactoryBot.define do
  factory :founder do
    first_name "John"
    last_name  "Doe"
    email "john@doe.com"

    trait :with_companies do
      after :create do |founder|
        create_list :company, 3, founders: [founder]
        # primary_company
      end
    end
  end
end
