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
    difficulty_level { :medium }
    translations_completed { false }
    description { "A delicious test recipe" }

    after(:build) do |recipe|

      # Add required ingredient group with recipe ingredient
      ingredient = Ingredient.find_or_create_by!(canonical_name: "test ingredient") { |i| i.category = "vegetable" }
      unit = Unit.find_or_create_by!(canonical_name: "cup") { |u| u.category = "unit_volume" }
      ig = recipe.ingredient_groups.build(name: "Ingredients", position: 1)
      ig.recipe_ingredients.build(
        ingredient_id: ingredient.id,
        ingredient_name: "test ingredient",
        amount: 1,
        unit: unit,
        position: 1
      )

      # Add required recipe step
      recipe.recipe_steps.build(step_number: 1, instruction_original: "Mix ingredients")

      # Add required cuisine
      cuisine = DataReference.find_or_create_by!(reference_type: 'cuisine', key: 'test') { |r| r.display_name = 'Test' }
      recipe.recipe_cuisines.build(data_reference: cuisine)

      # Attach images (card and detail)
      recipe.card_image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_card_image.png',
        content_type: 'image/png'
      )
      recipe.detail_image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_detail_image.png',
        content_type: 'image/png'
      )
    end

    after(:create) do |recipe|
      # Reattach images after save since attached files don't persist across build/create
      recipe.card_image.purge if recipe.card_image.attached?
      recipe.card_image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_card_image.png',
        content_type: 'image/png'
      )
      recipe.detail_image.purge if recipe.detail_image.attached?
      recipe.detail_image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_detail_image.png',
        content_type: 'image/png'
      )
    end
  end
end
