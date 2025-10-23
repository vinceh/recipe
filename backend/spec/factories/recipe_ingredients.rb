FactoryBot.define do
  factory :recipe_ingredient do
    ingredient_group
    ingredient_name { "Ingredient #{SecureRandom.hex(4)}" }
    amount { 1.0 }
    unit { "cup" }
    position { 1 }
    optional { false }
  end
end
