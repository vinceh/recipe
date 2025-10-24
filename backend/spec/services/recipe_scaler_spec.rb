require 'rails_helper'

RSpec.describe RecipeScaler, type: :service do
  describe '#scale_by_servings' do
    context 'AC-SCALE-001: Basic Proportional Scaling' do
      it 'doubles all ingredients when scaling from 4 to 8 servings' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 2,
               unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(8)

        expect(scaled[:ingredients].first[:amount]).to eq(4.0)
        expect(scaled[:ingredients].first[:unit]).to eq('cups')
      end

      it 'shows scaled servings display' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(8)

        expect(scaled[:servings]).to eq('8 servings (scaled from 4)')
      end
    end

    context 'AC-SCALE-002: Fractional Scaling with Friendly Fractions' do
      it 'halves all ingredients when scaling from 4 to 2 servings' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 2,
               unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(2)

        expect(scaled[:ingredients].first[:amount]).to eq(1.0)
        expect(scaled[:ingredients].first[:unit]).to eq('cups')
      end

      it 'displays friendly fractions for common decimals' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 1.5,
               unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(2)

        expect(scaled[:ingredients].first[:display_amount]).to eq('3/4 cup')
      end
    end

    context 'AC-SCALE-004: Context-Aware Precision - Baking Recipe' do
      it 'maintains 2 decimal places for baking recipes' do
        recipe = create(:recipe, servings_original: 4, servings_min: 1, servings_max: 8, requires_precision: true)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 250,
               unit: 'g')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(1.5)

        expect(scaled[:ingredients].first[:amount]).to eq(375.0)
      end

      it 'converts small amounts to grams in baking context' do
        recipe = create(:recipe, servings_original: 4, servings_min: 1, servings_max: 8, requires_precision: true)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 0.2,
               unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(1)

        expect(scaled[:ingredients].first[:unit]).to eq('g')
        expect(scaled[:ingredients].first[:amount]).to be_between(45, 50)
      end
    end

    context 'AC-SCALE-005: Context-Aware Precision - Cooking Recipe' do
      it 'rounds to friendly fractions for cooking recipes' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8, requires_precision: false)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 2,
               unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(1.5)

        expect(scaled[:ingredients].first[:display_amount]).to eq('3 cups')
      end

      it 'converts 0.66 cups to 2/3 cup' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8, requires_precision: false)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 0.66,
               unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(1)

        expect(scaled[:ingredients].first[:display_amount]).to eq('2/3 cup')
      end
    end

    context 'AC-SCALE-006: Unit Step-Down - Tablespoons to Teaspoons' do
      it 'steps down from tbsp to tsp for small amounts' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 1,
               unit: 'tbsp')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(0.5)

        expect(scaled[:ingredients].first[:unit]).to eq('tsp')
        expect(scaled[:ingredients].first[:display_amount]).to eq('1 1/2 tsp')
      end
    end

    context 'AC-SCALE-007: Unit Step-Down - Cups to Tablespoons' do
      it 'steps down from cups to tbsp for very small amounts' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 1,
               unit: 'cup')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(0.125)

        expect(scaled[:ingredients].first[:unit]).to eq('tbsp')
        expect(scaled[:ingredients].first[:display_amount]).to eq('2 tbsp')
      end
    end

    context 'AC-SCALE-008: Whole Item Rounding - Eggs (Cooking)' do
      it 'rounds eggs to nearest 0.5 for cooking recipes' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 3,
               unit: 'whole',
               canonical_name: 'egg')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(0.66)

        expect(scaled[:ingredients].first[:display_amount]).to eq('2 eggs')
      end
    end

    context 'AC-SCALE-009: Whole Item Rounding - Eggs (Baking)' do
      it 'converts eggs to grams in baking context' do
        recipe = create(:recipe, servings_original: 4, servings_min: 1, servings_max: 8, requires_precision: true)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 1,
               unit: 'whole',
               canonical_name: 'egg')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(0.5)

        expect(scaled[:ingredients].first[:unit]).to eq('g')
        expect(scaled[:ingredients].first[:display_amount]).to eq('25g beaten egg')
      end
    end

    context 'AC-SCALE-010: Whole Item Omit - Very Small Amounts' do
      it 'displays omit for amounts too small to be meaningful' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 1,
               unit: 'whole',
               canonical_name: 'garlic clove')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(0.2)

        expect(scaled[:ingredients].first[:display_amount]).to match(/omit|0 cloves/)
      end
    end
  end

  describe '#scale_by_ingredient' do
    context 'AC-SCALE-003: Calculate Scaling Factor from Target Ingredient' do
      it 'calculates correct scaling factor from ingredient target' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        chicken = create(:recipe_ingredient,
                        ingredient_group: ingredient_group,
                        amount: 500,
                        unit: 'g',
                        canonical_name: 'chicken thigh')
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 2,
               unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_ingredient(chicken.id, 200)

        expect(scaled[:ingredients][0][:amount]).to eq(200)
        expect(scaled[:ingredients][1][:amount]).to eq(0.8)
        expect(scaled[:servings]).to eq('1.6 servings (scaled from 4)')
      end

      it 'handles unit conversion in scaling factor calculation' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 1,
               unit: 'kg',
               canonical_name: 'flour')
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 2,
               unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_ingredient(recipe.recipe_ingredients.first.id, 500)

        expect(scaled[:ingredients].count).to eq(2)
      end
    end
  end

  describe '#scale_with_nutrition' do
    context 'AC-SCALE-011: Nutrition Recalculation on Scaling' do
      it 'maintains per-serving nutrition when scaling' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        create(:recipe_nutrition,
               recipe: recipe,
               calories: 2000,
               protein_g: 100,
               carbs_g: 200,
               fat_g: 50)

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(8)

        per_serving = scaled[:nutrition][:per_serving]
        expect(per_serving[:calories]).to eq(500)
        expect(per_serving[:protein_g]).to eq(25)
      end

      it 'multiplies total nutrition by serving count' do
        recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
        create(:recipe_nutrition,
               recipe: recipe,
               calories: 2000)

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(8)

        total = scaled[:nutrition][:total]
        expect(total[:calories]).to eq(4000)
      end
    end
  end

  describe 'AC-SCALE-012: Real-time Client-Side Scaling' do
    it 'calculates scaling within 100ms' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
      ingredient_group = create(:ingredient_group, recipe: recipe)
      create_list(:recipe_ingredient, 10, ingredient_group: ingredient_group)

      scaler = RecipeScaler.new(recipe)

      start_time = Time.current
      scaler.scale_by_servings(8)
      duration_ms = ((Time.current - start_time) * 1000).round

      expect(duration_ms).to be < 100
    end
  end

  describe '#round_to_friendly_fraction' do
    it 'rounds to whole numbers when close' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
      scaler = RecipeScaler.new(recipe)

      expect(scaler.round_to_friendly_fraction(0.95)).to eq('1')
      expect(scaler.round_to_friendly_fraction(2.05)).to eq('2')
    end

    it 'converts to friendly fractions' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
      scaler = RecipeScaler.new(recipe)

      expect(scaler.round_to_friendly_fraction(0.5)).to eq('1/2')
      expect(scaler.round_to_friendly_fraction(1.5)).to eq('1 1/2')
      expect(scaler.round_to_friendly_fraction(0.33)).to eq('1/3')
      expect(scaler.round_to_friendly_fraction(0.67)).to eq('2/3')
    end

    it 'handles mixed numbers' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
      scaler = RecipeScaler.new(recipe)

      expect(scaler.round_to_friendly_fraction(2.33)).to eq('2 1/3')
      expect(scaler.round_to_friendly_fraction(3.75)).to eq('3 3/4')
    end

    it 'falls back to 1 decimal for odd amounts' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
      scaler = RecipeScaler.new(recipe)

      expect(scaler.round_to_friendly_fraction(0.4)).to eq('0.4')
      expect(scaler.round_to_friendly_fraction(2.7)).to eq('2.7')
    end
  end

  describe '#find_ingredient_by_id' do
    it 'finds ingredient by id' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
      ingredient_group = create(:ingredient_group, recipe: recipe)
      ingredient = create(:recipe_ingredient, ingredient_group: ingredient_group)

      scaler = RecipeScaler.new(recipe)
      found = scaler.find_ingredient_by_id(ingredient.id)

      expect(found).to eq(ingredient)
    end

    it 'returns nil for non-existent id' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
      scaler = RecipeScaler.new(recipe)
      found = scaler.find_ingredient_by_id('nonexistent')

      expect(found).to be_nil
    end
  end

  describe 'context detection' do
    it 'detects baking context from requires_precision flag' do
      recipe = create(:recipe, servings_original: 4, servings_min: 1, servings_max: 8, requires_precision: true)
      scaler = RecipeScaler.new(recipe)

      expect(scaler.baking_context?).to be true
    end

    it 'detects baking context from recipe_types' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8)
      recipe_type = create(:data_reference, reference_type: 'recipe_type', key: 'bake')
      recipe.recipe_recipe_types.create(data_reference: recipe_type)

      scaler = RecipeScaler.new(recipe)

      expect(scaler.baking_context?).to be true
    end

    it 'defaults to cooking context for regular recipes' do
      recipe = create(:recipe, servings_original: 4, servings_min: 2, servings_max: 8, requires_precision: false)
      scaler = RecipeScaler.new(recipe)

      expect(scaler.baking_context?).to be false
    end
  end
end
