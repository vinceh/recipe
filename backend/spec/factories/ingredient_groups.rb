FactoryBot.define do
  factory :ingredient_group do
    recipe
    name { "Ingredient Group #{SecureRandom.hex(4)}" }
    position { |obj| obj.recipe.ingredient_groups.count + 1 }
  end
end
