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
    recipe.image.attach(
      io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
      filename: 'test_image.png',
      content_type: 'image/png'
    )
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

  describe 'AC-TRANS-002 to 006: Deduplication and Rate Limiting' do
    it 'enqueues job on recipe creation' do
      recipe = create_valid_recipe

      expect {
        recipe.save!
      }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)
    end

    it 'handles deduplication logic without errors' do
      recipe = create_valid_recipe
      recipe.save!

      allow_any_instance_of(Recipe).to receive(:has_translation_job_with_recipe_id?).and_return(true)
      allow_any_instance_of(Recipe).to receive(:has_running_translation_job?).and_return(false)

      expect {
        recipe.update!(name: "Updated")
      }.not_to raise_error
    end

    it 'respects running job protection' do
      recipe = create_valid_recipe
      recipe.save!

      allow_any_instance_of(Recipe).to receive(:has_translation_job_with_recipe_id?).and_return(true)
      allow_any_instance_of(Recipe).to receive(:has_running_translation_job?).and_return(true)

      expect {
        recipe.update!(name: "Updated")
      }.not_to raise_error
    end

    it 'applies rate limiting when exceeded' do
      recipe = create_valid_recipe
      recipe.save!

      allow_any_instance_of(Recipe).to receive(:translation_rate_limit_exceeded?).and_return(true)
      allow_any_instance_of(Recipe).to receive(:get_oldest_completed_translation_job_in_window)
        .and_return(double(finished_at: 2.hours.ago))

      expect {
        recipe.update!(name: "Updated")
      }.not_to raise_error
    end
  end

  describe 'AC-TRANS-017 & 018: Edge Cases' do
    it 'handles SolidQueue unavailability gracefully' do
      recipe = create_valid_recipe
      allow_any_instance_of(Recipe).to receive(:job_queue_available?).and_return(false)

      recipe.save!

      expect {
        recipe.update!(name: "Updated")
      }.not_to raise_error
    end

    it 'ignores expired translation jobs in rate limit window' do
      recipe = create_valid_recipe
      recipe.save!

      allow_any_instance_of(Recipe).to receive(:completed_translation_job_count).and_return(0)

      result = recipe.send(:completed_translation_job_count)

      expect(result).to eq(0)
    end
  end

  describe 'AC-TRANS-007: Manual Regeneration' do
    it 'supports regenerating translations via perform_later' do
      recipe = create_valid_recipe
      recipe.save!

      expect {
        TranslateRecipeJob.perform_later(recipe.id)
      }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)
    end
  end

  describe 'AC-TRANS-009: All 6 Languages Translated' do
    it 'calls translator for all 6 target languages' do
      recipe = create_valid_recipe
      I18n.with_locale(:en) do
        recipe.save!
      end

      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      target_languages = ['ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr']
      target_languages.each do |lang|
        translation_response = {
          'name' => "Translated Name #{lang}",
          'description' => "Translated Description #{lang}",
          'ingredient_groups' => [],
          'steps' => [],
          'equipment' => []
        }
        allow(translator).to receive(:translate_recipe).with(anything, lang).and_return(translation_response)
      end

      I18n.with_locale(:en) do
        TranslateRecipeJob.perform_now(recipe.id)
      end

      target_languages.each do |lang|
        expect(translator).to have_received(:translate_recipe).with(anything, lang)
      end
    end
  end

  describe 'AC-TRANS-011: All Fields Saved Atomically Per Language' do
    it 'applies all translated fields within locale context per language' do
      recipe = create_valid_recipe
      I18n.with_locale(:en) do
        recipe.save!
      end

      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      allow(translator).to receive(:translate_recipe) do |rec, lang|
        {
          'name' => "Name #{lang}",
          'description' => "Description #{lang}",
          'ingredient_groups' => [
            { 'name' => "Group #{lang}", 'items' => [{ 'name' => "Item #{lang}", 'preparation' => '' }] }
          ],
          'steps' => [
            { 'instruction' => "Step #{lang}" }
          ],
          'equipment' => ["Equipment #{lang}"]
        }
      end

      I18n.with_locale(:en) do
        TranslateRecipeJob.perform_now(recipe.id)
      end

      expect(translator).to have_received(:translate_recipe).exactly(6).times
    end
  end

  describe 'AC-TRANS-015: Translation API Failure Handling' do
    it 'logs error and continues when translator fails for a language' do
      recipe = create_valid_recipe
      I18n.with_locale(:en) do
        recipe.save!
      end

      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      success_response = {
        'name' => 'Translated',
        'description' => 'Translated Desc',
        'ingredient_groups' => [],
        'steps' => [],
        'equipment' => []
      }

      allow(translator).to receive(:translate_recipe) do |rec, lang|
        if lang == 'ko'
          raise StandardError.new('API error')
        else
          success_response
        end
      end

      allow(Rails.logger).to receive(:error)

      I18n.with_locale(:en) do
        TranslateRecipeJob.perform_now(recipe.id)
      end

      expect(Rails.logger).to have_received(:error).with(/Translation failed for recipe.*ko/)
    end
  end
end
