FactoryBot.define do
  factory :recipe_step do
    recipe
    step_number { 1 }
    instruction_original { "Mix the ingredients" }
  end
end
