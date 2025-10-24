FactoryBot.define do
  factory :recipe_nutrition do
    recipe
    calories { 500 }
    protein_g { 25 }
    carbs_g { 50 }
    fat_g { 15 }
    fiber_g { 5 }
  end
end
