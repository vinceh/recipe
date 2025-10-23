FactoryBot.define do
  factory :recipe_step do
    recipe
    step_number { 1 }
    instruction_original { "Mix the ingredients" }
    instruction_easier { nil }
    instruction_no_equipment { nil }
  end
end
