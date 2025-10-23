FactoryBot.define do
  factory :ingredient_alias do
    ingredient
    sequence(:alias) { |n| "Alias #{n}" }
    language { 'en' }
  end
end
