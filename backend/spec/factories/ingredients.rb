FactoryBot.define do
  factory :ingredient do
    sequence(:canonical_name) { |n| "Ingredient #{n}" }
    category { 'vegetable' }
  end
end
