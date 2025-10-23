FactoryBot.define do
  factory :ingredient_group do
    recipe
    name { "Ingredient Group #{SecureRandom.hex(4)}" }
    position { 1 }
  end
end
