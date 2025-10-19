require 'rails_helper'

RSpec.describe StepVariantGenerator do
  let(:recipe) do
    Recipe.create!(
      name: 'Test Recipe',
      language: 'en',
      servings: { 'original' => 4, 'min' => 1, 'max' => 12 },
      timing: { 'prep_minutes' => 10, 'cook_minutes' => 20, 'total_minutes' => 30 },
      dietary_tags: ['vegetarian'],
      ingredient_groups: [
        {
          'name' => 'Main Ingredients',
          'items' => [
            { 'id' => '1', 'name' => 'onions', 'amount' => 2, 'unit' => 'whole', 'preparation' => 'diced' },
            { 'id' => '2', 'name' => 'garlic', 'amount' => 3, 'unit' => 'cloves', 'preparation' => 'minced' }
          ]
        }
      ],
      steps: [
        {
          'id' => '1',
          'order' => 1,
          'title' => 'Prepare aromatics',
          'instructions' => {
            'original' => 'Sauté the onions and garlic until translucent'
          },
          'equipment' => ['pan', 'whisk']
        }
      ],
      dish_types: ['main-course'],
      recipe_types: ['dinner'],
      cuisines: ['american']
    )
  end

  let(:step) { recipe.steps.first }
  let(:generator) { described_class.new }
  let(:mock_client) { instance_double(Anthropic::Client) }

  before do
    # Stub Anthropic client initialization
    allow(Anthropic::Client).to receive(:new).and_return(mock_client)
  end

  before do
    # Seed AI prompts if not already present
    unless AiPrompt.exists?(prompt_key: 'step_variant_easier_system')
      AiPrompt.create!(
        prompt_key: 'step_variant_easier_system',
        prompt_type: 'system',
        feature_area: 'step_variants',
        description: 'System prompt for easier variants',
        variables: [],
        active: true,
        prompt_text: 'You are a cooking instructor.'
      )
    end

    unless AiPrompt.exists?(prompt_key: 'step_variant_easier_user')
      AiPrompt.create!(
        prompt_key: 'step_variant_easier_user',
        prompt_type: 'user',
        feature_area: 'step_variants',
        description: 'User prompt for easier variants',
        variables: ['recipe_name', 'cuisines', 'recipe_types', 'step_order', 'step_title',
                    'original_instruction', 'equipment', 'ingredients'],
        active: true,
        prompt_text: 'Recipe: {{recipe_name}}\nStep {{step_order}}: {{original_instruction}}'
      )
    end

    unless AiPrompt.exists?(prompt_key: 'step_variant_no_equipment_system')
      AiPrompt.create!(
        prompt_key: 'step_variant_no_equipment_system',
        prompt_type: 'system',
        feature_area: 'step_variants',
        description: 'System prompt for no-equipment variants',
        variables: [],
        active: true,
        prompt_text: 'You are a creative cooking expert.'
      )
    end

    unless AiPrompt.exists?(prompt_key: 'step_variant_no_equipment_user')
      AiPrompt.create!(
        prompt_key: 'step_variant_no_equipment_user',
        prompt_type: 'user',
        feature_area: 'step_variants',
        description: 'User prompt for no-equipment variants',
        variables: ['recipe_name', 'step_order', 'step_title', 'original_instruction', 'equipment'],
        active: true,
        prompt_text: 'Recipe: {{recipe_name}}\nEquipment: {{equipment}}\n{{original_instruction}}'
      )
    end
  end

  describe '#generate_easier_variant' do
    context 'when API returns valid JSON response' do
      it 'extracts text from JSON response' do
        allow(generator).to receive(:call_claude).and_return(
          '{"text": "Cook the onions in oil until they become see-through, about 3-5 minutes"}'
        )

        result = generator.generate_easier_variant(recipe, step)

        expect(result).to eq('Cook the onions in oil until they become see-through, about 3-5 minutes')
      end
    end

    context 'when API returns plain text response' do
      it 'returns the raw text' do
        allow(generator).to receive(:call_claude).and_return(
          'Cook the onions in oil until they become see-through'
        )

        result = generator.generate_easier_variant(recipe, step)

        expect(result).to eq('Cook the onions in oil until they become see-through')
      end
    end

    it 'includes recipe context in prompt' do
      expect(generator).to receive(:call_claude) do |args|
        expect(args[:user_prompt]).to include('Test Recipe')
        expect(args[:user_prompt]).to include('Step 1')
        expect(args[:user_prompt]).to include('Sauté the onions and garlic until translucent')
        '{"text": "result"}'
      end

      generator.generate_easier_variant(recipe, step)
    end

    it 'includes ingredient information in prompt' do
      expect(generator).to receive(:call_claude) do |args|
        expect(args[:user_prompt]).to include('onions')
        expect(args[:user_prompt]).to include('garlic')
        '{"text": "result"}'
      end

      generator.generate_easier_variant(recipe, step)
    end

    it 'includes equipment information in prompt' do
      # Update the prompt to include equipment placeholder
      AiPrompt.find_by(prompt_key: 'step_variant_easier_user').update!(
        prompt_text: 'Recipe: {{recipe_name}}\nEquipment: {{equipment}}\nStep {{step_order}}: {{original_instruction}}'
      )

      expect(generator).to receive(:call_claude) do |args|
        expect(args[:user_prompt]).to include('pan')
        expect(args[:user_prompt]).to include('whisk')
        '{"text": "result"}'
      end

      generator.generate_easier_variant(recipe, step)
    end
  end

  describe '#generate_no_equipment_variant' do
    context 'when API returns valid JSON response' do
      it 'extracts text from JSON response' do
        allow(generator).to receive(:call_claude).and_return(
          '{"text": "Use a fork instead of a whisk - whisk vigorously in circular motions"}'
        )

        result = generator.generate_no_equipment_variant(recipe, step)

        expect(result).to eq('Use a fork instead of a whisk - whisk vigorously in circular motions')
      end
    end

    context 'when API returns plain text' do
      it 'returns the raw text' do
        allow(generator).to receive(:call_claude).and_return(
          'Use a fork instead of a whisk'
        )

        result = generator.generate_no_equipment_variant(recipe, step)

        expect(result).to eq('Use a fork instead of a whisk')
      end
    end

    it 'includes equipment information in prompt' do
      expect(generator).to receive(:call_claude) do |args|
        expect(args[:user_prompt]).to include('pan')
        expect(args[:user_prompt]).to include('whisk')
        '{"text": "result"}'
      end

      generator.generate_no_equipment_variant(recipe, step)
    end
  end

  describe '#parse_variant_response' do
    it 'extracts text from valid JSON' do
      response = '{"text": "This is the variant text"}'
      result = generator.send(:parse_variant_response, response)
      expect(result).to eq('This is the variant text')
    end

    it 'returns raw text when JSON parsing fails' do
      response = 'Just plain text without JSON'
      result = generator.send(:parse_variant_response, response)
      expect(result).to eq('Just plain text without JSON')
    end

    it 'returns raw text when no JSON found' do
      response = 'Some text before and after'
      result = generator.send(:parse_variant_response, response)
      expect(result).to eq('Some text before and after')
    end

    it 'handles malformed JSON gracefully' do
      response = '{"text": "incomplete'
      result = generator.send(:parse_variant_response, response)
      expect(result).to eq('{"text": "incomplete')
    end
  end

  describe '#extract_step_ingredients' do
    it 'finds ingredients mentioned in step text' do
      result = generator.send(:extract_step_ingredients, recipe, step)

      expect(result).to include('2 whole onions')
      expect(result).to include('3 cloves garlic')
    end

    it 'returns empty array when no ingredients match' do
      step_without_ingredients = {
        'order' => 2,
        'instructions' => { 'original' => 'Serve immediately' }
      }

      result = generator.send(:extract_step_ingredients, recipe, step_without_ingredients)

      expect(result).to be_empty
    end

    it 'handles case-insensitive matching' do
      step_with_caps = {
        'order' => 1,
        'instructions' => { 'original' => 'Add ONIONS and GARLIC to the pan' }
      }

      result = generator.send(:extract_step_ingredients, recipe, step_with_caps)

      expect(result).not_to be_empty
    end

    it 'returns empty array when step text is nil' do
      step_without_text = {
        'order' => 1,
        'instructions' => {}
      }

      result = generator.send(:extract_step_ingredients, recipe, step_without_text)

      expect(result).to eq([])
    end
  end
end
