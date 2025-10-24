require 'rails_helper'

RSpec.describe TranslateRecipeJob, type: :job do
  let(:recipe) { create(:recipe, name: 'Test Recipe', translations_completed: false) }

  before do
    # Create translation prompts
    create(:ai_prompt,
      prompt_key: 'recipe_translation_system',
      prompt_type: 'system',
      feature_area: 'translation',
      prompt_text: 'You are a translator.',
      active: true
    )
    create(:ai_prompt,
      prompt_key: 'recipe_translation_user',
      prompt_type: 'user',
      feature_area: 'translation',
      prompt_text: 'Translate to {{target_language}}: {{recipe_json}}',
      active: true
    )
  end

  describe '#perform' do
    let(:ingredient_group) { create(:ingredient_group, recipe: recipe, name: 'Main Ingredients', position: 1) }
    let(:recipe_ingredient) { create(:recipe_ingredient, ingredient_group: ingredient_group, ingredient_name: 'Chicken') }
    let(:recipe_step) { create(:recipe_step, recipe: recipe, step_number: 1, instruction_original: 'Cook it') }
    let(:equipment) { create(:equipment, canonical_name: 'Pot') }

    before do
      ingredient_group
      recipe_ingredient
      recipe_step
      recipe.equipment << equipment
    end

    it 'translates recipe to all 6 languages via Mobility' do
      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        allow(translator).to receive(:translate_recipe)
          .with(recipe, lang)
          .and_return({
            'name' => "Recipe #{lang}",
            'ingredient_groups' => [{ 'name' => "Group #{lang}", 'items' => [] }],
            'steps' => [],
            'equipment' => []
          })
      end

      described_class.new.perform(recipe.id)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        expect(translator).to have_received(:translate_recipe).with(recipe, lang)
      end
    end

    it 'stores translations via Mobility translation tables' do
      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        allow(translator).to receive(:translate_recipe)
          .with(recipe, lang)
          .and_return({
            'name' => "Translated #{lang}",
            'ingredient_groups' => [{ 'name' => "Group #{lang}", 'items' => [] }],
            'steps' => [],
            'equipment' => []
          })
      end

      described_class.new.perform(recipe.id)

      # Verify translations stored in Mobility tables
      I18n.with_locale(:ja) do
        expect(recipe.reload.name).to eq('Translated ja')
        expect(ingredient_group.reload.name).to eq('Group ja')
      end

      I18n.with_locale(:es) do
        expect(recipe.reload.name).to eq('Translated es')
      end
    end

    it 'sets translations_completed to true' do
      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        allow(translator).to receive(:translate_recipe)
          .with(recipe, lang)
          .and_return({})
      end

      described_class.new.perform(recipe.id)
      recipe.reload

      expect(recipe.translations_completed).to be true
    end

    context 'when translation fails' do
      it 'logs error and re-raises exception' do
        allow(Recipe).to receive_message_chain(:includes, :includes, :find).and_raise(StandardError, 'Database error')
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(recipe.id)
        }.to raise_error(StandardError, 'Database error')

        expect(Rails.logger).to have_received(:error).with(/Unexpected error in translation job for recipe/)
      end

      it 'logs and silently handles recipe not found' do
        allow(Recipe).to receive_message_chain(:includes, :includes, :find).and_raise(ActiveRecord::RecordNotFound)
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(999)
        }.not_to raise_error

        expect(Rails.logger).to have_received(:error).with(/Recipe not found for translation job/)
      end
    end
  end

  describe 'AC-TRANSLATE-001: Pre-Translation on Save' do
    it 'can be enqueued after recipe creation' do
      expect {
        TranslateRecipeJob.perform_later(recipe.id)
      }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)
    end

    it 'processes all 6 languages and marks complete via Mobility' do
      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        allow(translator).to receive(:translate_recipe)
          .with(recipe, lang)
          .and_return({
            'name' => "Name in #{lang}",
            'ingredient_groups' => [],
            'steps' => [],
            'equipment' => []
          })
      end

      described_class.new.perform(recipe.id)
      recipe.reload

      # Verify all 6 languages were translated
      RecipeTranslator::LANGUAGES.keys.each do |lang|
        I18n.with_locale(lang) do
          expect(recipe.reload.name).to eq("Name in #{lang}")
        end
      end

      expect(recipe.translations_completed).to be true
    end
  end

  describe 'queue configuration' do
    it 'uses default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end
  end
end
