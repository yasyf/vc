FactoryBot.define do
  factory :investor do
    university

    sequence :first_name do |n|
      "Jane #{n}"
    end
    last_name "Risk"
    sequence :email do |n|
      "jane#{n}@risk.com"
    end
    competitor
  end
end
