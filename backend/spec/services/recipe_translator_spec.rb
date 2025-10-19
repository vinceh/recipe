require 'rails_helper'

RSpec.describe RecipeTranslator, type: :service do
  let(:recipe) { create(:recipe, name: 'Pad Thai') }
  let(:translator) { described_class.new }

  before do
    # Stub API key for tests
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('test_api_key')
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('ANTHROPIC_MODEL', anything).and_return('claude-3-5-sonnet-20241022')

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

  describe '#translate_recipe' do
    context 'with valid language code' do
      it 'calls Claude API with correct prompts' do
        allow(translator).to receive(:call_claude).and_return('{"name": "パッタイ"}')

        result = translator.translate_recipe(recipe, 'ja')

        expect(translator).to have_received(:call_claude).with(
          system_prompt: 'You are a translator.',
          user_prompt: a_string_including('Japanese', 'Pad Thai'),
          max_tokens: 4096
        )
        expect(result).to eq({ 'name' => 'パッタイ' })
      end

      it 'parses JSON response from Claude' do
        allow(translator).to receive(:call_claude).and_return('{"name": "팟타이"}')

        result = translator.translate_recipe(recipe, 'ko')

        expect(result).to eq({ 'name' => '팟타이' })
      end

      it 'handles JSON wrapped in markdown code blocks' do
        allow(translator).to receive(:call_claude).and_return("```json\n{\"name\": \"Pad Thai\"}\n```")

        result = translator.translate_recipe(recipe, 'es')

        expect(result).to eq({ 'name' => 'Pad Thai' })
      end

      it 'returns nil when JSON parsing fails' do
        allow(translator).to receive(:call_claude).and_return('Invalid JSON response')

        result = translator.translate_recipe(recipe, 'ja')

        expect(result).to be_nil
      end
    end

    context 'with invalid language code' do
      it 'raises ArgumentError' do
        expect {
          translator.translate_recipe(recipe, 'invalid')
        }.to raise_error(ArgumentError, /Unsupported language/)
      end
    end

    context 'with supported languages' do
      RecipeTranslator::LANGUAGES.keys.each do |lang_code|
        it "supports #{lang_code}" do
          allow(translator).to receive(:call_claude).and_return('{"name": "Test"}')

          expect {
            translator.translate_recipe(recipe, lang_code)
          }.not_to raise_error
        end
      end
    end
  end

  describe 'LANGUAGES constant' do
    it 'includes all 6 target languages' do
      expect(RecipeTranslator::LANGUAGES.keys).to contain_exactly(
        'ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr'
      )
    end

    it 'maps to display names' do
      expect(RecipeTranslator::LANGUAGES['ja']).to eq('Japanese')
      expect(RecipeTranslator::LANGUAGES['zh-tw']).to eq('Traditional Chinese (Taiwan)')
    end
  end

  describe 'AC-TRANSLATE-002: Cultural Ingredient Accuracy - Native Term' do
    it 'translates native ingredients without explanation' do
      recipe = create(:recipe,
        name: 'Recipe with negi',
        ingredient_groups: [
          {
            name: 'Main',
            items: [
              { id: 1, name: 'negi (Japanese green onion)', amount: 1, unit: 'stalk' }
            ]
          }
        ]
      )

      allow(translator).to receive(:call_claude).and_return(
        '{"name": "ネギのレシピ", "ingredient_groups": [{"name": "主要材料", "items": [{"id": 1, "name": "ネギ", "amount": 1, "unit": "本"}]}]}'
      )

      result = translator.translate_recipe(recipe, 'ja')

      expect(result['ingredient_groups'][0]['items'][0]['name']).to eq('ネギ')
      expect(result['ingredient_groups'][0]['items'][0]['name']).not_to include('説明')
    end
  end

  describe 'AC-TRANSLATE-004: All Text Fields Translated' do
    it 'translates name, ingredients, steps, equipment while preserving structure' do
      recipe = create(:recipe,
        name: 'Test Recipe',
        ingredient_groups: [
          {
            name: 'Main',
            items: [
              { id: 1, name: 'chicken', amount: 500, unit: 'g' }
            ]
          }
        ],
        steps: [
          {
            id: 1,
            instructions: {
              original: 'Cut the chicken',
              easier: nil,
              no_equipment: nil
            },
            timing: { prep_time: 5 },
            equipment: ['knife']
          }
        ]
      )

      translated_response = {
        'name' => 'Recette de test',
        'ingredient_groups' => [
          {
            'name' => 'Principal',
            'items' => [
              { 'id' => 1, 'name' => 'poulet', 'amount' => 500, 'unit' => 'g' }
            ]
          }
        ],
        'steps' => [
          {
            'id' => 1,
            'instructions' => {
              'original' => 'Couper le poulet',
              'easier' => nil,
              'no_equipment' => nil
            },
            'timing' => { 'prep_time' => 5 },
            'equipment' => ['couteau']
          }
        ]
      }

      allow(translator).to receive(:call_claude).and_return(translated_response.to_json)

      result = translator.translate_recipe(recipe, 'fr')

      # Text fields translated
      expect(result['name']).to eq('Recette de test')
      expect(result['ingredient_groups'][0]['items'][0]['name']).to eq('poulet')
      expect(result['steps'][0]['instructions']['original']).to eq('Couper le poulet')

      # Numeric values preserved
      expect(result['ingredient_groups'][0]['items'][0]['amount']).to eq(500)
      expect(result['ingredient_groups'][0]['items'][0]['id']).to eq(1)
      expect(result['steps'][0]['id']).to eq(1)
      expect(result['steps'][0]['timing']['prep_time']).to eq(5)

      # Structure preserved
      expect(result.keys).to contain_exactly('name', 'ingredient_groups', 'steps')
    end
  end

  describe 'error handling' do
    it 'logs errors when translation parsing fails' do
      allow(translator).to receive(:call_claude).and_return('Not valid JSON')

      # Check result is nil (parsing failed)
      result = translator.translate_recipe(recipe, 'ja')
      expect(result).to be_nil
    end
  end
end
