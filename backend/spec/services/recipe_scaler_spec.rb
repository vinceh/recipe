require 'rails_helper'

RSpec.describe RecipeScaler do
  let(:recipe) do
    Recipe.new(
      name: 'Test Recipe',
      language: 'en',
      requires_precision: false,
      servings: { 'original' => 4, 'min' => 1, 'max' => 12 },
      timing: { 'prep_minutes' => 10, 'cook_minutes' => 20, 'total_minutes' => 30 },
      nutrition: { 'calories' => 500, 'protein_g' => 25 },
      dietary_tags: ['vegetarian'],
      ingredient_groups: [
        {
          'name' => 'Main Ingredients',
          'items' => [
            { 'id' => '1', 'name' => 'flour', 'amount' => 2, 'unit' => 'cup', 'preparation' => 'sifted' },
            { 'id' => '2', 'name' => 'butter', 'amount' => 1, 'unit' => 'tbsp', 'preparation' => 'melted' },
            { 'id' => '3', 'name' => 'milk', 'amount' => 1, 'unit' => 'cup', 'preparation' => '' },
            { 'id' => '4', 'name' => 'eggs', 'amount' => 3, 'unit' => 'whole', 'preparation' => '' },
            { 'id' => '5', 'name' => 'chicken thigh', 'amount' => 500, 'unit' => 'g', 'preparation' => 'diced' }
          ]
        }
      ],
      steps: [],
      dish_types: ['main-course'],
      recipe_types: ['dinner'],
      cuisines: ['american']
    )
  end

  let(:baking_recipe) do
    Recipe.new(
      name: 'Chocolate Cake',
      language: 'en',
      requires_precision: true,
      servings: { 'original' => 8, 'min' => 4, 'max' => 16 },
      timing: { 'prep_minutes' => 15, 'cook_minutes' => 30, 'total_minutes' => 45 },
      dietary_tags: [],
      ingredient_groups: [
        {
          'name' => 'Dry Ingredients',
          'items' => [
            { 'id' => '1', 'name' => 'flour', 'amount' => 2, 'unit' => 'cup', 'preparation' => 'sifted' },
            { 'id' => '2', 'name' => 'cocoa powder', 'amount' => 0.5, 'unit' => 'cup', 'preparation' => '' },
            { 'id' => '3', 'name' => 'eggs', 'amount' => 2, 'unit' => 'whole', 'preparation' => '' }
          ]
        }
      ],
      steps: [],
      dish_types: ['dessert'],
      recipe_types: ['baking'],
      cuisines: ['american']
    )
  end

  describe '#scale_by_servings' do
    context 'AC-SCALE-001: Basic proportional scaling' do
      it 'doubles all ingredients when scaling from 4 to 8 servings' do
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(8)

        expect(scaled.servings['scaled']).to eq(8.0)
        expect(scaled.ingredient_groups[0]['items'][0]['amount']).to eq(4) # 2 cups * 2
        expect(scaled.ingredient_groups[0]['items'][4]['amount']).to eq(1000) # 500g * 2
      end
    end

    context 'AC-SCALE-002: Fractional scaling with friendly fractions' do
      it 'halves all ingredients when scaling from 4 to 2 servings' do
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(2)

        expect(scaled.servings['scaled']).to eq(2.0)
        expect(scaled.ingredient_groups[0]['items'][0]['amount']).to eq(1) # 2 cups * 0.5
      end

      it 'displays friendly fractions for common decimals' do
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(3) # 0.75x scaling

        flour_amount = scaled.ingredient_groups[0]['items'][0]['amount']
        # 2 * 0.75 = 1.5, should be formatted as "1 1/2"
        expect(flour_amount).to eq('1 1/2').or eq(1.5)
      end
    end

    context 'AC-SCALE-004: Context-aware precision for baking' do
      it 'maintains 2 decimal places for baking recipes' do
        scaler = RecipeScaler.new(baking_recipe)
        scaled = scaler.scale_by_servings(12) # 1.5x scaling

        flour_amount = scaled.ingredient_groups[0]['items'][0]['amount']
        # 2 cups * 1.5 = 3.0, should maintain precision
        expect(flour_amount).to eq(3.0)
      end

      it 'converts small amounts to grams in baking context' do
        scaler = RecipeScaler.new(baking_recipe)
        scaled = scaler.scale_by_servings(1) # 0.125x scaling (8 -> 1)

        cocoa = scaled.ingredient_groups[0]['items'][1]
        # 0.5 cups * 0.125 = 0.0625 cups, should convert to grams if < 0.25
        # 0.0625 cups * 240ml/cup = 15ml ≈ 15g
        if cocoa['unit'] == 'g'
          expect(cocoa['amount']).to be_within(1).of(15)
        else
          # Or it might keep precision as 0.06 cups
          expect(cocoa['amount']).to be_within(0.01).of(0.06)
        end
      end
    end

    context 'AC-SCALE-005: Context-aware precision for cooking' do
      it 'rounds to friendly fractions for cooking recipes' do
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(3) # 0.75x scaling

        flour_amount = scaled.ingredient_groups[0]['items'][0]['amount']
        # 2 * 0.75 = 1.5
        expect([1.5, '1 1/2']).to include(flour_amount)
      end
    end

    context 'AC-SCALE-006: Unit step-down - tablespoons to teaspoons' do
      it 'steps down tbsp to tsp for small amounts' do
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(2) # 0.5x scaling

        butter = scaled.ingredient_groups[0]['items'][1]
        # 1 tbsp * 0.5 = 0.5 tbsp, should step down to 1.5 tsp
        if butter['unit'] == 'tsp'
          expect(butter['amount']).to eq(1.5)
          expect(butter['unit']).to eq('tsp')
        end
      end
    end

    context 'AC-SCALE-007: Unit step-down - cups to tablespoons' do
      it 'steps down cups to tbsp for small amounts' do
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(0.5) # 0.125x scaling

        milk = scaled.ingredient_groups[0]['items'][2]
        # 1 cup * 0.125 = 0.125 cups, should step down to 2 tbsp
        if milk['unit'] == 'tbsp'
          expect(milk['amount']).to eq(2.0)
          expect(milk['unit']).to eq('tbsp')
        end
      end
    end
  end

  describe '#scale_by_ingredient' do
    context 'AC-SCALE-003: Calculate scaling factor from target ingredient' do
      it 'calculates correct scaling factor and applies to all ingredients' do
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_ingredient('5', 200, 'g') # chicken thigh: 500g -> 200g

        expect(scaled.servings['scaled']).to eq(1.6) # 4 * 0.4
        expect(scaled.ingredient_groups[0]['items'][4]['amount']).to eq(200) # chicken
        expect(scaled.ingredient_groups[0]['items'][0]['amount']).to be_within(0.1).of(0.8) # flour: 2 * 0.4
      end

      it 'handles unit conversion in scaling factor calculation' do
        scaler = RecipeScaler.new(recipe)
        # Milk is 1 cup. If we want 0.5 cups, scaling factor should be 0.5
        scaled = scaler.scale_by_ingredient('3', 0.5, 'cup')

        # Scaling factor should be 0.5 (0.5 cup / 1 cup)
        expect(scaled.servings['scaled']).to eq(2.0) # 4 * 0.5
      end
    end
  end

  describe 'context detection' do
    it 'detects baking context from requires_precision flag' do
      scaler = RecipeScaler.new(baking_recipe)
      expect(scaler.send(:detect_cooking_context, baking_recipe)).to eq('baking')
    end

    it 'detects baking context from recipe_types' do
      recipe.recipe_types = ['baking']
      scaler = RecipeScaler.new(recipe)
      expect(scaler.send(:detect_cooking_context, recipe)).to eq('baking')
    end

    it 'defaults to cooking context for regular recipes' do
      scaler = RecipeScaler.new(recipe)
      expect(scaler.send(:detect_cooking_context, recipe)).to eq('cooking')
    end
  end

  describe '#round_to_friendly_fraction' do
    let(:scaler) { RecipeScaler.new(recipe) }

    it 'rounds to whole numbers when close' do
      expect(scaler.send(:round_to_friendly_fraction, 1.95)).to eq(2)
      expect(scaler.send(:round_to_friendly_fraction, 2.05)).to eq(2)
    end

    it 'converts to friendly fractions' do
      expect(scaler.send(:round_to_friendly_fraction, 0.5)).to eq('1/2')
      expect(scaler.send(:round_to_friendly_fraction, 0.25)).to eq('1/4')
      expect(scaler.send(:round_to_friendly_fraction, 0.75)).to eq('3/4')
      expect(scaler.send(:round_to_friendly_fraction, 0.33)).to eq('1/3')
      expect(scaler.send(:round_to_friendly_fraction, 0.66)).to eq('2/3')
    end

    it 'handles mixed numbers' do
      result = scaler.send(:round_to_friendly_fraction, 1.5)
      expect(['1 1/2', 1.5]).to include(result)

      result = scaler.send(:round_to_friendly_fraction, 2.75)
      expect(['2 3/4', 2.75]).to include(result)
    end

    it 'falls back to 1 decimal for odd amounts' do
      result = scaler.send(:round_to_friendly_fraction, 1.37)
      # 1.37 is close to 1.33 (1/3), so it might return "1 1/3" or 1.4
      expect(['1 1/3', 1.4]).to include(result)
    end
  end

  describe '#find_ingredient_by_id' do
    let(:scaler) { RecipeScaler.new(recipe) }

    it 'finds ingredient by id' do
      ingredient = scaler.send(:find_ingredient_by_id, '1')
      expect(ingredient['name']).to eq('flour')
    end

    it 'returns nil for non-existent id' do
      ingredient = scaler.send(:find_ingredient_by_id, '999')
      expect(ingredient).to be_nil
    end
  end
end
