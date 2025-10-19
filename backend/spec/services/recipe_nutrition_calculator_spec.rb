require 'rails_helper'

RSpec.describe RecipeNutritionCalculator, type: :service do
  let(:recipe) do
    create(:recipe,
      name: 'Test Recipe',
      servings: { original: 4, min: 2, max: 8 },
      ingredient_groups: [
        {
          name: 'Main',
          items: [
            { id: 1, name: 'chicken breast', amount: 500, unit: 'g' },
            { id: 2, name: 'rice', amount: 200, unit: 'g' }
          ]
        }
      ]
    )
  end

  let(:calculator) { described_class.new(recipe) }
  let(:lookup_service) { instance_double(NutritionLookupService) }

  before do
    allow(NutritionLookupService).to receive(:new).and_return(lookup_service)
  end

  describe '#calculate' do
    before do
      # Mock nutrition lookups
      allow(lookup_service).to receive(:lookup_ingredient).with('chicken breast', 'en')
        .and_return({
          calories: 165,
          protein_g: 31,
          carbs_g: 0,
          fat_g: 3.6,
          fiber_g: 0
        })

      allow(lookup_service).to receive(:lookup_ingredient).with('rice', 'en')
        .and_return({
          calories: 130,
          protein_g: 2.7,
          carbs_g: 28,
          fat_g: 0.3,
          fiber_g: 0.4
        })
    end

    context 'AC-NUTR-008: Recipe Nutrition Calculation - Per Serving' do
      it 'calculates total nutrition correctly' do
        result = calculator.calculate

        # 500g chicken: 165 * 5 = 825 cal
        # 200g rice: 130 * 2 = 260 cal
        # Total: 1085 cal
        expect(result[:total][:calories]).to eq(1085)
      end

      it 'calculates per-serving nutrition' do
        result = calculator.calculate

        # Total 1085 cal / 4 servings = 271.25 → 271
        expect(result[:per_serving][:calories]).to eq(271)
      end

      it 'rounds per-serving values appropriately' do
        result = calculator.calculate

        expect(result[:per_serving][:calories]).to be_an(Integer)
        expect(result[:per_serving][:protein_g]).to be_a(Float)
      end
    end

    context 'AC-NUTR-009: Unit Conversion - Volume to Weight' do
      it 'converts cups to grams for flour' do
        recipe = create(:recipe,
          name: 'Flour Test',
          servings: { original: 1, min: 1, max: 4 },
          ingredient_groups: [
            {
              name: 'Main',
              items: [{ id: 1, name: 'flour', amount: 1, unit: 'cup' }]
              }
          ]
        )

        allow(lookup_service).to receive(:lookup_ingredient).with('flour', 'en')
          .and_return({ calories: 364, protein_g: 10, carbs_g: 76, fat_g: 1, fiber_g: 3 })

        calculator = described_class.new(recipe)
        result = calculator.calculate

        # 1 cup flour ≈ 120g (240ml * 0.5 density)
        # 364 cal/100g * 1.2 = 436.8 cal
        expect(result[:total][:calories]).to be_within(5).of(437)
      end

      it 'converts tablespoons to grams for oil' do
        recipe = create(:recipe,
          name: 'Oil Test',
          servings: { original: 1, min: 1, max: 4 },
          ingredient_groups: [
            {
              name: 'Main',
              items: [{ id: 1, name: 'olive oil', amount: 2, unit: 'tbsp' }]
            }
          ]
        )

        allow(lookup_service).to receive(:lookup_ingredient).with('olive oil', 'en')
          .and_return({ calories: 884, protein_g: 0, carbs_g: 0, fat_g: 100, fiber_g: 0 })

        calculator = described_class.new(recipe)
        result = calculator.calculate

        # 2 tbsp = 30ml * 0.92 density = 27.6g
        # 884 * 0.276 = 243.98
        expect(result[:total][:calories]).to be_within(5).of(244)
      end
    end

    context 'whole item conversions' do
      it 'converts whole eggs to grams' do
        recipe = create(:recipe,
          name: 'Egg Test',
          servings: { original: 1, min: 1, max: 4 },
          ingredient_groups: [
            {
              name: 'Main',
              items: [{ id: 1, name: 'eggs', amount: 3, unit: 'whole' }]
            }
          ]
        )

        allow(lookup_service).to receive(:lookup_ingredient).with('eggs', 'en')
          .and_return({ calories: 143, protein_g: 13, carbs_g: 1, fat_g: 10, fiber_g: 0 })

        calculator = described_class.new(recipe)
        result = calculator.calculate

        # 3 eggs * 50g = 150g
        # 143 cal/100g * 1.5 = 214.5
        expect(result[:total][:calories]).to be_within(2).of(215)
      end
    end

    context 'weight unit conversions' do
      it 'converts kilograms to grams' do
        grams = calculator.send(:convert_to_grams, 1.5, 'kg', 'chicken')
        expect(grams).to eq(1500)
      end

      it 'converts ounces to grams' do
        grams = calculator.send(:convert_to_grams, 4, 'oz', 'chicken')
        expect(grams).to eq(113.4)
      end

      it 'converts pounds to grams' do
        grams = calculator.send(:convert_to_grams, 1, 'lb', 'beef')
        expect(grams).to eq(453.592)
      end
    end
  end

  describe 'private methods' do
    describe '#estimate_grams_from_ml' do
      it 'uses water density for stock' do
        grams = calculator.send(:estimate_grams_from_ml, 'chicken stock', 240)
        expect(grams).to eq(240)  # 1.0 density
      end

      it 'uses appropriate density for oil' do
        grams = calculator.send(:estimate_grams_from_ml, 'olive oil', 100)
        expect(grams).to eq(92)  # 0.92 density
      end

      it 'uses appropriate density for honey' do
        grams = calculator.send(:estimate_grams_from_ml, 'honey', 100)
        expect(grams).to eq(140)  # 1.4 density
      end

      it 'uses flour density' do
        grams = calculator.send(:estimate_grams_from_ml, 'flour', 240)
        expect(grams).to eq(120)  # 0.5 density
      end
    end

    describe '#estimate_grams_from_count' do
      it 'estimates egg weight' do
        grams = calculator.send(:estimate_grams_from_count, 'eggs', 2)
        expect(grams).to eq(100)  # 50g each
      end

      it 'estimates chicken breast weight' do
        grams = calculator.send(:estimate_grams_from_count, 'chicken breast', 1)
        expect(grams).to eq(150)
      end

      it 'uses default for unknown items' do
        grams = calculator.send(:estimate_grams_from_count, 'unknown item', 1)
        expect(grams).to eq(100)
      end
    end

    describe '#estimate_grams_from_volume' do
      it 'converts cups correctly' do
        grams = calculator.send(:estimate_grams_from_volume, 'water', 1, 'cup')
        expect(grams).to eq(240)  # 240ml * 1.0 density
      end

      it 'converts tablespoons correctly' do
        grams = calculator.send(:estimate_grams_from_volume, 'water', 2, 'tbsp')
        expect(grams).to eq(30)  # 30ml * 1.0 density
      end

      it 'converts teaspoons correctly' do
        grams = calculator.send(:estimate_grams_from_volume, 'water', 3, 'tsp')
        expect(grams).to eq(15)  # 15ml * 1.0 density
      end
    end
  end
end
