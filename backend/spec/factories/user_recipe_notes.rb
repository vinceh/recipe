FactoryBot.define do
  factory :user_recipe_note do
    user
    recipe
    notes { 'Test note' }
  end
end
