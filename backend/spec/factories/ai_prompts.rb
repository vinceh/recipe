FactoryBot.define do
  factory :ai_prompt do
    sequence(:prompt_key) { |n| "test_prompt_#{n}" }
    prompt_type { 'system' }
    feature_area { 'step_variants' }
    prompt_text { 'Test prompt text' }
    description { 'Test prompt description' }
    variables { [] }
    active { true }
  end
end
