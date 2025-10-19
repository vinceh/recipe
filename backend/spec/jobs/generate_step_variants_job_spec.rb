require 'rails_helper'

RSpec.describe GenerateStepVariantsJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers
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
            { 'id' => '1', 'name' => 'onions', 'amount' => 2, 'unit' => 'whole' }
          ]
        }
      ],
      steps: [
        {
          'id' => '1',
          'order' => 1,
          'title' => 'Step 1',
          'instructions' => {
            'original' => 'Sauté the onions until translucent'
          },
          'equipment' => ['pan']
        },
        {
          'id' => '2',
          'order' => 2,
          'title' => 'Step 2',
          'instructions' => {
            'original' => 'Add the sauce and simmer'
          },
          'equipment' => ['pot']
        }
      ],
      dish_types: ['main-course'],
      recipe_types: ['dinner'],
      cuisines: ['american'],
      variants_generated: false
    )
  end

  let(:generator) { instance_double(StepVariantGenerator) }

  before do
    allow(StepVariantGenerator).to receive(:new).and_return(generator)
  end

  describe '#perform' do
    context 'AC-VARIANT-007: Variants pre-generated on save' do
      it 'generates easier and no-equipment variants for all steps' do
        allow(generator).to receive(:generate_easier_variant).and_return('Easier variant text')
        allow(generator).to receive(:generate_no_equipment_variant).and_return('No equipment variant text')

        described_class.new.perform(recipe.id)

        recipe.reload
        expect(recipe.steps[0]['instructions']['easier']).to eq('Easier variant text')
        expect(recipe.steps[0]['instructions']['no_equipment']).to eq('No equipment variant text')
        expect(recipe.steps[1]['instructions']['easier']).to eq('Easier variant text')
        expect(recipe.steps[1]['instructions']['no_equipment']).to eq('No equipment variant text')
      end

      it 'sets variants_generated flag to true' do
        allow(generator).to receive(:generate_easier_variant).and_return('Easier text')
        allow(generator).to receive(:generate_no_equipment_variant).and_return('No equipment text')

        described_class.new.perform(recipe.id)

        recipe.reload
        expect(recipe.variants_generated).to be true
      end

      it 'records variants_generated_at timestamp' do
        allow(generator).to receive(:generate_easier_variant).and_return('Easier text')
        allow(generator).to receive(:generate_no_equipment_variant).and_return('No equipment text')

        travel_to Time.zone.local(2025, 10, 7, 12, 0, 0) do
          described_class.new.perform(recipe.id)

          recipe.reload
          expect(recipe.variants_generated_at).to be_within(1.second).of(Time.current)
        end
      end
    end

    context 'when step has no original instruction' do
      it 'skips variant generation for that step' do
        recipe.steps[0]['instructions'] = {}
        recipe.save!

        allow(generator).to receive(:generate_easier_variant).and_return('Easier text')
        allow(generator).to receive(:generate_no_equipment_variant).and_return('No equipment text')

        described_class.new.perform(recipe.id)

        recipe.reload
        expect(recipe.steps[0]['instructions']['easier']).to be_nil
        expect(recipe.steps[0]['instructions']['no_equipment']).to be_nil
        # But second step should still be generated
        expect(recipe.steps[1]['instructions']['easier']).to eq('Easier text')
      end
    end

    context 'when generator raises an error' do
      it 'logs error and does not update recipe' do
        allow(generator).to receive(:generate_easier_variant).and_raise(StandardError.new('API error'))

        expect(Rails.logger).to receive(:error).with(/Variant generation failed/)

        described_class.new.perform(recipe.id)

        recipe.reload
        expect(recipe.variants_generated).to be false
      end

      it 'does not raise exception to Sidekiq' do
        allow(generator).to receive(:generate_easier_variant).and_raise(StandardError.new('API error'))

        expect { described_class.new.perform(recipe.id) }.not_to raise_error
      end
    end

    context 'when recipe has multiple steps' do
      before do
        recipe.steps << {
          'id' => '3',
          'order' => 3,
          'title' => 'Step 3',
          'instructions' => { 'original' => 'Serve hot' },
          'equipment' => []
        }
        recipe.save!
      end

      it 'generates variants for all steps' do
        allow(generator).to receive(:generate_easier_variant).and_return('Easier text')
        allow(generator).to receive(:generate_no_equipment_variant).and_return('No equipment text')

        described_class.new.perform(recipe.id)

        recipe.reload
        expect(recipe.steps.length).to eq(3)
        recipe.steps.each do |step|
          expect(step['instructions']['easier']).to eq('Easier text')
          expect(step['instructions']['no_equipment']).to eq('No equipment text')
        end
      end
    end

    context 'when recipe does not exist' do
      it 'logs error and does not crash' do
        # Use a valid UUID format
        non_existent_id = '00000000-0000-0000-0000-000000000000'

        expect(Rails.logger).to receive(:error).with(/Variant generation failed/)

        # Job should handle the error gracefully
        expect {
          described_class.new.perform(non_existent_id)
        }.not_to raise_error
      end
    end

    context 'rate limiting and API usage' do
      it 'calls generator twice per step (easier + no_equipment)' do
        allow(generator).to receive(:generate_easier_variant).and_return('Easier text')
        allow(generator).to receive(:generate_no_equipment_variant).and_return('No equipment text')

        described_class.new.perform(recipe.id)

        # 2 steps × 2 variants each = 4 total calls
        expect(generator).to have_received(:generate_easier_variant).exactly(2).times
        expect(generator).to have_received(:generate_no_equipment_variant).exactly(2).times
      end
    end

    context 'variant quality' do
      it 'preserves step order and structure' do
        allow(generator).to receive(:generate_easier_variant).and_return('Easier text')
        allow(generator).to receive(:generate_no_equipment_variant).and_return('No equipment text')

        described_class.new.perform(recipe.id)

        recipe.reload
        expect(recipe.steps[0]['order']).to eq(1)
        expect(recipe.steps[1]['order']).to eq(2)
        expect(recipe.steps[0]['title']).to eq('Step 1')
        expect(recipe.steps[0]['equipment']).to eq(['pan'])
      end

      it 'keeps original instruction unchanged' do
        original_instruction = recipe.steps[0]['instructions']['original']

        allow(generator).to receive(:generate_easier_variant).and_return('Easier text')
        allow(generator).to receive(:generate_no_equipment_variant).and_return('No equipment text')

        described_class.new.perform(recipe.id)

        recipe.reload
        expect(recipe.steps[0]['instructions']['original']).to eq(original_instruction)
      end
    end
  end
end
