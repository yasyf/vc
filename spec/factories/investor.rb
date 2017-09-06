FactoryGirl.define do
  factory :investor do
    first_name "Jane"
    last_name "Risk"
    email "jane@risk.com"
    competitor
  end
end