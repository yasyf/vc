FactoryBot.define do
  factory :competitor do
    sequence :name do |n|
      "VC Fund #{n}"
    end
    trait :with_companies do
      after :create do |competitor|
        create_list :company, 3, competitors: [competitor]
      end
    end
  end
end