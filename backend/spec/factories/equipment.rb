FactoryBot.define do
  factory :equipment do
    sequence(:canonical_name) { |n| "Equipment #{n}" }
  end
end
