FactoryGirl.define do
  factory :company do
    name "NewCo"
    industry [:food]
    description "A great company!"

    trait :verified do
      verified true
    end

    trait :with_external do
      crunchbase_id 1
      al_id 1
    end
  end
end