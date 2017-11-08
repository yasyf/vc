FactoryBot.define do
  factory :import_task do
    founder nil
    preview ""
    complete false
    imported 1
    errored "MyText"
  end
end
