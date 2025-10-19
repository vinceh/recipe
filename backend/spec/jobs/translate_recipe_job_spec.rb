require 'rails_helper'

RSpec.describe TranslateRecipeJob, type: :job do
  let(:recipe) { create(:recipe, name: 'Test Recipe', translations: {}, translations_completed: false) }

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
    it 'translates recipe to all 6 languages' do
      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        allow(translator).to receive(:translate_recipe)
          .with(recipe, lang)
          .and_return({ 'name' => "Translated #{lang}" })
      end

      described_class.new.perform(recipe.id)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        expect(translator).to have_received(:translate_recipe).with(recipe, lang)
      end
    end

    it 'updates recipe with translations hash' do
      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        allow(translator).to receive(:translate_recipe)
          .with(recipe, lang)
          .and_return({ 'name' => "Translated #{lang}" })
      end

      described_class.new.perform(recipe.id)
      recipe.reload

      expect(recipe.translations).to be_a(Hash)
      expect(recipe.translations.keys).to contain_exactly('ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr')
      expect(recipe.translations['ja']).to eq({ 'name' => 'Translated ja' })
    end

    it 'sets translations_completed to true' do
      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        allow(translator).to receive(:translate_recipe).and_return({})
      end

      described_class.new.perform(recipe.id)
      recipe.reload

      expect(recipe.translations_completed).to be true
    end

    context 'when translation fails' do
      it 'logs error and re-raises exception' do
        allow(Recipe).to receive(:find).and_raise(StandardError, 'Database error')
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(recipe.id)
        }.to raise_error(StandardError, 'Database error')

        expect(Rails.logger).to have_received(:error).with(/Translation failed for recipe/)
      end
    end
  end

  describe 'AC-TRANSLATE-001: Pre-Translation on Save' do
    it 'can be enqueued after recipe creation' do
      expect {
        TranslateRecipeJob.perform_later(recipe.id)
      }.to have_enqueued_job(TranslateRecipeJob).with(recipe.id)
    end

    it 'processes all 6 languages and marks complete' do
      translator = instance_double(RecipeTranslator)
      allow(RecipeTranslator).to receive(:new).and_return(translator)

      RecipeTranslator::LANGUAGES.keys.each do |lang|
        allow(translator).to receive(:translate_recipe)
          .with(recipe, lang)
          .and_return({ 'name' => "Name in #{lang}" })
      end

      described_class.new.perform(recipe.id)
      recipe.reload

      expect(recipe.translations.size).to eq(6)
      expect(recipe.translations_completed).to be true
    end
  end

  describe 'queue configuration' do
    it 'uses default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end
  end
end
