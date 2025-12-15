FactoryBot.define do
  factory :ingredient_nutrition do
    association :ingredient
    calories { 100 }
    protein_g { 10 }
    carbs_g { 10 }
    fat_g { 5 }
    fiber_g { 2 }
    data_source { 'usda' }
    confidence_score { 1.0 }
  end
end
