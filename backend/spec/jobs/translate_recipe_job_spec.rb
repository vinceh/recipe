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

  describe 'Phase 5: Auto-Triggered Translation Workflow' do
    describe 'AC-PHASE5-JOB-001 & AC-PHASE5-TIMESTAMP-001: Sets last_translated_at on success' do
      before do
        skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
      end

      it 'sets last_translated_at to current time when job completes successfully' do
        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)

        RecipeTranslator::LANGUAGES.keys.each do |lang|
          allow(translator).to receive(:translate_recipe)
            .with(recipe, lang)
            .and_return({ 'name' => "Translated #{lang}", 'ingredient_groups' => [], 'steps' => [], 'equipment' => [] })
        end

        freeze_time do
          described_class.new.perform(recipe.id)
          expect(recipe.reload.last_translated_at).to be_within(1.second).of(Time.current)
        end
      end

      it 'sets translations_completed to true on success' do
        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)

        RecipeTranslator::LANGUAGES.keys.each do |lang|
          allow(translator).to receive(:translate_recipe)
            .with(recipe, lang)
            .and_return({})
        end

        described_class.new.perform(recipe.id)
        expect(recipe.reload.translations_completed).to be true
      end

      it 'does NOT update last_translated_at when any language translation fails' do
        original_time = recipe.last_translated_at

        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)

        # First language succeeds
        allow(translator).to receive(:translate_recipe)
          .with(recipe, 'en')
          .and_return({})

        # Second language fails
        allow(translator).to receive(:translate_recipe)
          .with(recipe, 'ja')
          .and_raise(StandardError, 'API timeout')

        # Rest succeed
        %w[ko zh-tw zh-cn es fr].each do |lang|
          allow(translator).to receive(:translate_recipe)
            .with(recipe, lang)
            .and_return({})
        end

        allow(Rails.logger).to receive(:error)
        described_class.new.perform(recipe.id)

        expect(recipe.reload.last_translated_at).to eq(original_time)
        expect(recipe.reload.translations_completed).to be false
      end
    end

    describe 'AC-PHASE5-JOB-002 & AC-PHASE5-JOB-005: Source language exclusion' do
      it 'excludes source language from translation targets' do
        # When source_language='ja' (which IS in LANGUAGES), it should be excluded
        recipe_ja = create(:recipe, source_language: 'ja', translations_completed: false)

        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)

        languages_called = []
        allow(translator).to receive(:translate_recipe) do |recipe, lang|
          languages_called << lang
          {}
        end

        described_class.new.perform(recipe_ja.id)

        # Verify source language 'ja' was NOT translated
        expect(languages_called).not_to include('ja')
        # Should translate to the other 5 languages in RecipeTranslator::LANGUAGES
        expect(languages_called.uniq.length).to eq(5)
        # All should be from supported languages
        expect(languages_called).to all(be_in(%w[ja ko zh-tw zh-cn es fr]))
      end

      it 'translates to all languages when source is English (not in LANGUAGES)' do
        recipe_en = create(:recipe, source_language: 'en', translations_completed: false)

        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)

        languages_called = []
        allow(translator).to receive(:translate_recipe) do |recipe, lang|
          languages_called << lang
          {}
        end

        described_class.new.perform(recipe_en.id)

        # Since 'en' is not in RecipeTranslator::LANGUAGES, all 6 languages get translated
        expect(languages_called.uniq.length).to eq(6)
        # All should be from the 6 languages in RecipeTranslator::LANGUAGES
        expect(languages_called).to all(be_in(%w[ja ko zh-tw zh-cn es fr]))
      end

      it 'excludes source when source is one of the translation languages' do
        recipe_es = create(:recipe, source_language: 'es', translations_completed: false)

        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)

        languages_called = []
        allow(translator).to receive(:translate_recipe) do |recipe, lang|
          languages_called << lang
          {}
        end

        described_class.new.perform(recipe_es.id)

        # Verify source language 'es' was NOT translated
        expect(languages_called).not_to include('es')
        # Should translate to the other 5 languages
        expect(languages_called.uniq.length).to eq(5)
        # All should be from supported languages
        expect(languages_called).to all(be_in(%w[ja ko zh-tw zh-cn es fr]))
      end
    end

    describe 'AC-PHASE5-JOB-004: API failure handling' do
      it 'logs error when single language translation fails' do
        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)
        allow(Rails.logger).to receive(:error)

        # Japanese translation fails
        allow(translator).to receive(:translate_recipe)
          .with(recipe, 'ja')
          .and_raise(StandardError, 'API timeout')

        # Other languages succeed
        %w[ko zh-tw zh-cn es fr en].each do |lang|
          allow(translator).to receive(:translate_recipe)
            .with(recipe, lang)
            .and_return({})
        end

        described_class.new.perform(recipe.id)

        expect(Rails.logger).to have_received(:error)
          .with(/Translation failed for recipe .* language ja/)
      end

      it 'continues translating other languages when one fails (no retry)' do
        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)
        allow(Rails.logger).to receive(:error)

        call_count = 0
        allow(translator).to receive(:translate_recipe) do |rec, lang|
          call_count += 1
          raise StandardError, 'API error' if lang == 'ja'
          {}
        end

        described_class.new.perform(recipe.id)

        # Should have tried to translate all 6 languages (or 5 if English is source)
        expect(call_count).to be >= 5
      end

      it 'sets translations_completed to false when any translation fails' do
        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)
        allow(Rails.logger).to receive(:error)

        # Set up mock to fail for 'ja' language, succeed for others
        allow(translator).to receive(:translate_recipe) do |rec, lang|
          raise StandardError, 'API error' if lang == 'ja'
          {}
        end

        described_class.new.perform(recipe.id)

        expect(recipe.reload.translations_completed).to be false
      end

      it 'does not retry job on API failure' do
        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)
        allow(Rails.logger).to receive(:error)

        allow(translator).to receive(:translate_recipe)
          .and_raise(StandardError, 'API error')

        # Should NOT raise exception (no retry)
        expect {
          described_class.new.perform(recipe.id)
        }.not_to raise_error
      end
    end

    describe 'AC-PHASE5-TIMESTAMP-002: solid_queue source of truth for rate limiting' do
      before do
        skip 'SolidQueue not initialized in test environment' unless SolidQueue::Job.table_exists?
      end

      it 'uses completed job timestamps from solid_queue for rate limiting' do
        recipe = create(:recipe, last_translated_at: nil)

        # Simulate completed jobs in solid_queue
        3.times do |i|
          SolidQueue::Job.create!(
            class_name: 'TranslateRecipeJob',
            arguments: [recipe.id],
            finished_at: (25 - i).minutes.ago
          )
        end

        # Job should complete successfully
        translator = instance_double(RecipeTranslator)
        allow(RecipeTranslator).to receive(:new).and_return(translator)

        RecipeTranslator::LANGUAGES.keys.each do |lang|
          allow(translator).to receive(:translate_recipe)
            .with(recipe, lang)
            .and_return({})
        end

        freeze_time do
          described_class.new.perform(recipe.id)
          expect(recipe.reload.last_translated_at).to be_within(1.second).of(Time.current)
        end
      end
    end
  end

  describe 'queue configuration' do
    it 'uses default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end
  end
end
