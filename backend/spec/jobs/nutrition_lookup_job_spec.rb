require 'rails_helper'

RSpec.describe NutritionLookupJob, type: :job do
  let(:recipe) do
    create(:recipe,
      name: 'Test Recipe',
      servings: { original: 4, min: 2, max: 8 },
      ingredient_groups: [
        {
          name: 'Main',
          items: [
            { id: 1, name: 'chicken', amount: 500, unit: 'g' }
          ]
        }
      ],
      nutrition: {}
    )
  end

  describe '#perform' do
    it 'calculates and updates recipe nutrition' do
      calculator = instance_double(RecipeNutritionCalculator)
      allow(RecipeNutritionCalculator).to receive(:new).with(recipe).and_return(calculator)
      allow(calculator).to receive(:calculate).and_return({
        total: { calories: 825, protein_g: 155, carbs_g: 0, fat_g: 18, fiber_g: 0 },
        per_serving: { calories: 206, protein_g: 38.8, carbs_g: 0, fat_g: 4.5, fiber_g: 0 }
      })

      described_class.new.perform(recipe.id)
      recipe.reload

      expect(recipe.nutrition['per_serving']['calories']).to eq(206)
      expect(recipe.nutrition['total']['calories']).to eq(825)
    end

    it 'handles calculation errors gracefully' do
      allow(RecipeNutritionCalculator).to receive(:new).and_raise(StandardError, 'Calculation failed')
      allow(Rails.logger).to receive(:error)

      described_class.new.perform(recipe.id)
      recipe.reload

      expect(Rails.logger).to have_received(:error).with(/Nutrition calculation failed/)
      expect(recipe.nutrition['per_serving']['calories']).to eq(0)
    end

    it 'sets default values on error' do
      allow(RecipeNutritionCalculator).to receive(:new).and_raise(StandardError)

      described_class.new.perform(recipe.id)
      recipe.reload

      expect(recipe.nutrition['per_serving']).to include(
        'calories' => 0,
        'protein_g' => 0,
        'carbs_g' => 0,
        'fat_g' => 0,
        'fiber_g' => 0
      )
    end
  end

  describe 'queue configuration' do
    it 'uses default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end
  end

  describe 'enqueuing' do
    it 'can be enqueued' do
      expect {
        NutritionLookupJob.perform_later(recipe.id)
      }.to have_enqueued_job(NutritionLookupJob).with(recipe.id)
    end
  end
end
