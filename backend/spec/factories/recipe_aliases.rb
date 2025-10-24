FactoryBot.define do
  factory :recipe_alias do
    recipe
    alias_name { "Recipe Alias #{SecureRandom.hex(4)}" }
  end
end
