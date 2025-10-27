require 'rails_helper'

RSpec.describe 'Recipe Translation Workflow', type: :model do
  let(:cuisine) do
    DataReference.find_or_create_by!(reference_type: 'cuisine', key: 'test') { |r| r.display_name = 'Test' }
  end

  def create_valid_recipe
    recipe = Recipe.new(
      name: "Test Recipe #{SecureRandom.hex(4)}",
      description: "A delicious recipe",
      source_language: "en",
      servings_original: 2,
      prep_minutes: 10,
      cook_minutes: 20,
      total_minutes: 30
    )
    recipe.recipe_steps.build(step_number: 1, instruction_original: "Mix ingredients")
    ig = recipe.ingredient_groups.build(name: "Ingredients", position: 1)
    ingredient = Ingredient.find_or_create_by!(canonical_name: "test ingredient") { |i| i.category = "vegetable" }
    ig.recipe_ingredients.build(ingredient_id: ingredient.id, ingredient_name: "test ingredient", amount: 1, unit: "cup", position: 1)
    recipe.recipe_cuisines.build(data_reference: cuisine)
    recipe
  end

  describe 'AC-TRANS-001: Immediate job on create' do
    it 'enqueues TranslateRecipeJob immediately after save' do
      recipe = create_valid_recipe

      expect {
        recipe.save!
      }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id).on_queue('default')
    end
  end

  describe 'AC-TRANS-008 & 010 & 016: Description field handling' do
    it 'includes description in recipe with Mobility support' do
      recipe = create_valid_recipe
      recipe.save!

      I18n.with_locale(:en) do
        recipe.reload
        expect(recipe.description).to eq("A delicious recipe")
      end

      translation = RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'en')
      expect(translation.description).to eq("A delicious recipe")
    end
  end

  describe 'Job queue availability' do
    it 'gracefully handles when job queue is unavailable' do
      recipe = create_valid_recipe
      allow_any_instance_of(Recipe).to receive(:job_queue_available?).and_return(false)

      expect {
        recipe.save!
        recipe.update!(name: "Updated")
      }.not_to raise_error
    end
  end
end
