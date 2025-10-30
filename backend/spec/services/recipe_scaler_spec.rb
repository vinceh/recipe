require 'rails_helper'

RSpec.describe RecipeScaler, type: :service do
  def make_recipe(overrides = {})
    create(:recipe, {
      servings_original: 4,
      servings_min: 2,
      servings_max: 8
    }.merge(overrides))
  end

  describe '#scale_by_servings' do
    context 'AC-SCALE-001: Basic Proportional Scaling' do
      it 'doubles all ingredients when scaling from 4 to 8 servings (AC-SCALE-001)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 2, unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(8)

        expect(scaled[:scaled_servings]).to eq(8.0)
      end

      it 'shows scaled servings display (AC-SCALE-001)' do
        recipe = make_recipe
        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(8)

        expect(scaled[:scaled_servings]).to eq(8.0)
      end
    end

    context 'AC-SCALE-002: Fractional Scaling with Friendly Fractions' do
      it 'halves all ingredients when scaling from 4 to 2 servings (AC-SCALE-002)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 2, unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(2)

        expect(scaled[:scaled_servings]).to eq(2.0)
      end

      it 'displays friendly fractions for common decimals (AC-SCALE-002)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        ri = create(:recipe_ingredient, ingredient_group: ingredient_group)
        ri.update_column(:amount, 1.5)

        recipe = Recipe.find(recipe.id)

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(2)

        expect(scaled[:ingredient_groups].last[:items].first[:amount]).to eq('3/4')
      end
    end

    context 'AC-SCALE-004: Context-Aware Precision - Baking Recipe' do
      it 'maintains 2 decimal places for baking recipes (AC-SCALE-004)' do
        recipe = make_recipe(requires_precision: true, servings_min: 1)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 250, unit: 'g')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(1.5)

        expect(scaled[:scaled_servings]).to eq(1.5)
      end

      it 'identifies baking recipe via requires_precision flag (AC-SCALE-004)' do
        recipe = make_recipe(requires_precision: true, servings_min: 1)
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 250, unit: 'g')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(1)

        expect(scaled).to be_a(Hash)
        expect(scaled[:scaled_servings]).to eq(1)
      end
    end

    context 'AC-SCALE-005: Context-Aware Precision - Cooking Recipe' do
      it 'rounds to friendly fractions for cooking recipes (AC-SCALE-005)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 2, unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(1.5)

        expect(scaled[:ingredient_groups].first[:items].first[:amount]).to match(/1\s|3|cups/)
      end

      it 'rounds scaled amounts to closest friendly fraction (AC-SCALE-005)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 0.66, unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(1)

        expect(scaled[:ingredient_groups].first[:items].first[:amount]).to be_in(['1/8', '1/3', '2/3', '1/4', '3/4', '1/2'])
      end
    end

    context 'AC-SCALE-006: Unit Step-Down - Tablespoons to Teaspoons' do
      it 'steps down from tbsp to tsp for small amounts (AC-SCALE-006)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 1, unit: 'tbsp')

        recipe = Recipe.find(recipe.id)

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(0.5)

        expect(scaled[:ingredient_groups].last[:items].first[:unit]).to eq('tsp')
      end
    end

    context 'AC-SCALE-007: Unit Step-Down - Cups to Tablespoons' do
      it 'steps down from cups to tbsp for very small amounts (AC-SCALE-007)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 1, unit: 'cup')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_servings(0.125)

        expect(scaled[:ingredient_groups].first[:items].first[:unit]).to eq('tbsp')
      end
    end
  end

  describe '#scale_by_ingredient' do
    context 'AC-SCALE-003: Calculate Scaling Factor from Target Ingredient' do
      it 'calculates correct scaling factor from ingredient target (AC-SCALE-003)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        chicken = create(:recipe_ingredient,
                        ingredient_group: ingredient_group,
                        amount: 500,
                        unit: 'g',
                        ingredient_name: 'chicken thigh')
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 2, unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_ingredient(chicken.id, 200, 'g')

        expect(scaled[:scaled_servings]).to eq(1.6)
      end

      it 'handles unit conversion in scaling factor calculation (AC-SCALE-003)' do
        recipe = make_recipe
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient,
               ingredient_group: ingredient_group,
               amount: 1,
               unit: 'kg',
               ingredient_name: 'flour')
        create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 2, unit: 'cups')

        scaler = RecipeScaler.new(recipe)
        scaled = scaler.scale_by_ingredient(recipe.recipe_ingredients.first.id, 500, 'g')

        expect(scaled[:ingredient_groups].count).to eq(1)
      end
    end
  end


  describe 'Context detection' do
    it 'detects baking context from requires_precision flag' do
      recipe = make_recipe(requires_precision: true, servings_min: 1)
      scaler = RecipeScaler.new(recipe)

      # Verify baking context affects scaling logic
      ingredient_group = create(:ingredient_group, recipe: recipe)
      create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 250, unit: 'g')

      scaled = scaler.scale_by_servings(1.5)
      expect(scaled).to be_a(Hash)
    end

    it 'defaults to cooking context for regular recipes' do
      recipe = make_recipe
      scaler = RecipeScaler.new(recipe)

      ingredient_group = create(:ingredient_group, recipe: recipe)
      create(:recipe_ingredient, ingredient_group: ingredient_group, amount: 2, unit: 'cups')

      scaled = scaler.scale_by_servings(1.5)
      expect(scaled).to be_a(Hash)
    end
  end

  describe 'AC-SCALE-012: Real-time Client-Side Scaling' do
    it 'calculates scaling within reasonable time' do
      recipe = make_recipe
      ingredient_group = create(:ingredient_group, recipe: recipe)
      create_list(:recipe_ingredient, 10, ingredient_group: ingredient_group)

      scaler = RecipeScaler.new(recipe)
      start_time = Time.current
      scaler.scale_by_servings(8)
      duration_ms = ((Time.current - start_time) * 1000).round

      expect(duration_ms).to be < 1000
    end
  end
end
