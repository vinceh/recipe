FactoryBot.define do
  factory :recipe do
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
      recipe.name = "Test Recipe #{SecureRandom.hex(4)}"

      # Add required ingredient group with recipe ingredient
      ingredient = Ingredient.find_or_create_by!(canonical_name: "test ingredient") { |i| i.category = "vegetable" }
      ig = recipe.ingredient_groups.build(name: "Ingredients", position: 1)
      ig.recipe_ingredients.build(
        ingredient_id: ingredient.id,
        ingredient_name: "test ingredient",
        amount: 1,
        unit: "cup",
        position: 1
      )

      # Add required recipe step
      recipe.recipe_steps.build(step_number: 1, instruction_original: "Mix ingredients")

      # Add required cuisine
      cuisine = DataReference.find_or_create_by!(reference_type: 'cuisine', key: 'test') { |r| r.display_name = 'Test' }
      recipe.recipe_cuisines.build(data_reference: cuisine)

      # Attach image
      recipe.image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_image.png',
        content_type: 'image/png'
      )
    end

    after(:create) do |recipe|
      # Reattach image after save since attached files don't persist across build/create
      recipe.image.purge if recipe.image.attached?
      recipe.image.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
        filename: 'test_image.png',
        content_type: 'image/png'
      )
    end
  end
end
