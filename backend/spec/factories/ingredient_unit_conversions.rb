FactoryBot.define do
  factory :ingredient_unit_conversion do
    association :ingredient
    association :unit
    grams { 100 }
  end
end
