FactoryBot.define do
  factory :recipe do
    name { "Test Recipe #{SecureRandom.hex(4)}" }
    source_language { 'en' }
    servings_original { 2 }
    servings_min { 2 }
    servings_max { 4 }
    prep_minutes { 10 }
    cook_minutes { 20 }
    total_minutes { 30 }
    requires_precision { false }
    variants_generated { false }
    translations_completed { false }
  end
end
