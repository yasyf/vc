FactoryGirl.define do
  factory :competitor do
    name "VC Fund"
    trait :with_companies do
      after :create do |competitor|
        create_list :company, 3, competitors: [competitor]
      end
    end
  end
end