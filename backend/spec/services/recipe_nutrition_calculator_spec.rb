require 'rails_helper'

RSpec.describe RecipeNutritionCalculator, type: :service do
  def create_ingredient_with_nutrition(name, nutrition_attrs = {})
    ingredient = create(:ingredient, canonical_name: name)
    default_nutrition = {
      calories: 100,
      protein_g: 10,
      carbs_g: 10,
      fat_g: 5,
      fiber_g: 2
    }
    create(:ingredient_nutrition, ingredient: ingredient, **default_nutrition.merge(nutrition_attrs))
    ingredient
  end

  describe '#convert_to_grams' do
    let(:recipe) { create(:recipe) }
    let(:calculator) { described_class.new(recipe) }

    context 'Weight conversions' do
      it 'test 1: converts grams directly' do
        ingredient = create_ingredient_with_nutrition('flour', calories: 364)
        result = calculator.send(:convert_to_grams, 200, 'g', 'flour', ingredient)
        expect(result).to eq(200)
      end

      it 'test 2: converts kilograms to grams' do
        ingredient = create_ingredient_with_nutrition('potatoes', calories: 77)
        result = calculator.send(:convert_to_grams, 2, 'kg', 'potatoes', ingredient)
        expect(result).to eq(2000)
      end

      it 'test 3: converts ounces to grams' do
        ingredient = create_ingredient_with_nutrition('cheese', calories: 400)
        result = calculator.send(:convert_to_grams, 4, 'oz', 'cheese', ingredient)
        expect(result).to be_within(0.1).of(113.4)
      end

      it 'test 4: converts pounds to grams' do
        ingredient = create_ingredient_with_nutrition('beef', calories: 250)
        result = calculator.send(:convert_to_grams, 1, 'lb', 'beef', ingredient)
        expect(result).to be_within(0.1).of(453.592)
      end

      it 'test 5: handles fractional weight amounts' do
        ingredient = create_ingredient_with_nutrition('butter', calories: 717)
        result = calculator.send(:convert_to_grams, 0.5, 'lb', 'butter', ingredient)
        expect(result).to be_within(0.1).of(226.796)
      end
    end

    context 'Volume conversions' do
      it 'test 6: converts cups using density' do
        ingredient = create_ingredient_with_nutrition('water', calories: 0)
        result = calculator.send(:convert_to_grams, 1, 'cup', 'water', ingredient)
        expect(result).to eq(240)
      end

      it 'test 7: converts tablespoons' do
        ingredient = create_ingredient_with_nutrition('soy sauce', calories: 53)
        result = calculator.send(:convert_to_grams, 2, 'tbsp', 'soy sauce', ingredient)
        expect(result).to eq(30)
      end

      it 'test 8: converts teaspoons' do
        ingredient = create_ingredient_with_nutrition('salt', calories: 0)
        result = calculator.send(:convert_to_grams, 1, 'tsp', 'salt', ingredient)
        expect(result).to eq(5)
      end

      it 'test 9: converts milliliters' do
        ingredient = create_ingredient_with_nutrition('chicken stock', calories: 9)
        result = calculator.send(:convert_to_grams, 500, 'ml', 'chicken stock', ingredient)
        expect(result).to eq(500)
      end

      it 'test 10: converts liters' do
        ingredient = create_ingredient_with_nutrition('broth', calories: 10)
        result = calculator.send(:convert_to_grams, 1.5, 'l', 'broth', ingredient)
        expect(result).to eq(1500)
      end
    end

    context 'Density-based volume conversions' do
      it 'test 11: applies oil density (0.92)' do
        ingredient = create_ingredient_with_nutrition('olive oil', calories: 884)
        result = calculator.send(:convert_to_grams, 1, 'cup', 'olive oil', ingredient)
        expect(result).to be_within(0.1).of(240 * 0.92)
      end

      it 'test 12: applies butter density (0.92)' do
        ingredient = create_ingredient_with_nutrition('butter', calories: 717)
        result = calculator.send(:convert_to_grams, 2, 'tbsp', 'butter', ingredient)
        expect(result).to be_within(0.1).of(30 * 0.92)
      end

      it 'test 13: applies flour density (0.5)' do
        ingredient = create_ingredient_with_nutrition('all-purpose flour', calories: 364)
        result = calculator.send(:convert_to_grams, 1, 'cup', 'all-purpose flour', ingredient)
        expect(result).to be_within(0.1).of(240 * 0.5)
      end

      it 'test 14: applies sugar density (0.85)' do
        ingredient = create_ingredient_with_nutrition('sugar', calories: 387)
        result = calculator.send(:convert_to_grams, 1, 'cup', 'sugar', ingredient)
        expect(result).to be_within(0.1).of(240 * 0.85)
      end

      it 'test 15: applies honey density (1.4)' do
        ingredient = create_ingredient_with_nutrition('honey', calories: 304)
        result = calculator.send(:convert_to_grams, 2, 'tbsp', 'honey', ingredient)
        expect(result).to be_within(0.1).of(30 * 1.4)
      end

      it 'test 16: applies milk density (1.03)' do
        ingredient = create_ingredient_with_nutrition('milk', calories: 42)
        result = calculator.send(:convert_to_grams, 1, 'cup', 'milk', ingredient)
        expect(result).to be_within(0.1).of(240 * 1.03)
      end

      it 'test 17: applies cream density (1.03)' do
        ingredient = create_ingredient_with_nutrition('heavy cream', calories: 340)
        result = calculator.send(:convert_to_grams, 0.5, 'cup', 'heavy cream', ingredient)
        expect(result).to be_within(0.1).of(120 * 1.03)
      end

      it 'test 18: applies rice density (0.75)' do
        ingredient = create_ingredient_with_nutrition('rice', calories: 130)
        result = calculator.send(:convert_to_grams, 2, 'cup', 'rice', ingredient)
        expect(result).to be_within(0.1).of(480 * 0.75)
      end

      it 'test 19: applies syrup density (1.4)' do
        ingredient = create_ingredient_with_nutrition('maple syrup', calories: 260)
        result = calculator.send(:convert_to_grams, 3, 'tbsp', 'maple syrup', ingredient)
        expect(result).to be_within(0.1).of(45 * 1.4)
      end

      it 'test 20: applies default density for unknown liquids' do
        ingredient = create_ingredient_with_nutrition('wine', calories: 82)
        result = calculator.send(:convert_to_grams, 1, 'cup', 'wine', ingredient)
        expect(result).to eq(240)
      end
    end

    context 'Count-based conversions' do
      it 'test 21: converts whole eggs' do
        ingredient = create_ingredient_with_nutrition('eggs', calories: 143)
        result = calculator.send(:convert_to_grams, 3, 'whole', 'eggs', ingredient)
        expect(result).to eq(150)
      end

      it 'test 22: converts piece for tomatoes' do
        ingredient = create_ingredient_with_nutrition('tomato', calories: 18)
        result = calculator.send(:convert_to_grams, 2, 'piece', 'tomato', ingredient)
        expect(result).to eq(200)
      end

      it 'test 23: converts item for onions' do
        ingredient = create_ingredient_with_nutrition('onion', calories: 40)
        result = calculator.send(:convert_to_grams, 1, 'item', 'onion', ingredient)
        expect(result).to eq(150)
      end

      it 'test 24: converts nil unit as count' do
        ingredient = create_ingredient_with_nutrition('potatoes', calories: 77)
        result = calculator.send(:convert_to_grams, 4, nil, 'potatoes', ingredient)
        expect(result).to eq(600)
      end

      it 'test 25: converts chicken breast count' do
        ingredient = create_ingredient_with_nutrition('chicken breast', calories: 165)
        result = calculator.send(:convert_to_grams, 2, 'whole', 'chicken breast', ingredient)
        expect(result).to eq(300)
      end

      it 'test 26: converts carrots count' do
        ingredient = create_ingredient_with_nutrition('carrot', calories: 41)
        result = calculator.send(:convert_to_grams, 3, 'whole', 'carrot', ingredient)
        expect(result).to eq(180)
      end

      it 'test 27: converts bananas count' do
        ingredient = create_ingredient_with_nutrition('banana', calories: 89)
        result = calculator.send(:convert_to_grams, 2, 'piece', 'banana', ingredient)
        expect(result).to eq(240)
      end

      it 'test 28: converts apples count' do
        ingredient = create_ingredient_with_nutrition('apple', calories: 52)
        result = calculator.send(:convert_to_grams, 3, 'whole', 'apple', ingredient)
        expect(result).to eq(450)
      end

      it 'test 29: uses default weight for unknown items' do
        ingredient = create_ingredient_with_nutrition('exotic fruit', calories: 50)
        result = calculator.send(:convert_to_grams, 2, 'piece', 'exotic fruit', ingredient)
        expect(result).to eq(200)
      end
    end

    context 'Database unit conversions (IngredientUnitConversion)' do
      it 'test 30: uses database conversion for corn tortillas' do
        ingredient = create_ingredient_with_nutrition('corn tortillas', calories: 218)
        whole_unit = Unit.find_or_create_by!(canonical_name: 'whole') { |u| u.category = 'unit_quantity' }
        create(:ingredient_unit_conversion, ingredient: ingredient, unit: whole_unit, grams: 26)

        result = calculator.send(:convert_to_grams, 8, 'whole', 'corn tortillas', ingredient)
        expect(result).to eq(208)
      end

      it 'test 31: uses database conversion for scallions' do
        ingredient = create_ingredient_with_nutrition('scallions', calories: 32)
        whole_unit = Unit.find_or_create_by!(canonical_name: 'whole') { |u| u.category = 'unit_quantity' }
        create(:ingredient_unit_conversion, ingredient: ingredient, unit: whole_unit, grams: 15)

        result = calculator.send(:convert_to_grams, 4, 'whole', 'scallions', ingredient)
        expect(result).to eq(60)
      end

      it 'test 32: uses database conversion for garlic cloves' do
        ingredient = create_ingredient_with_nutrition('garlic', calories: 149)
        clove_unit = Unit.find_or_create_by!(canonical_name: 'clove') { |u| u.category = 'unit_quantity' }
        create(:ingredient_unit_conversion, ingredient: ingredient, unit: clove_unit, grams: 3)

        result = calculator.send(:convert_to_grams, 6, 'clove', 'garlic', ingredient)
        expect(result).to eq(18)
      end

      it 'test 33: uses database conversion for lime' do
        ingredient = create_ingredient_with_nutrition('lime', calories: 30)
        whole_unit = Unit.find_or_create_by!(canonical_name: 'whole') { |u| u.category = 'unit_quantity' }
        create(:ingredient_unit_conversion, ingredient: ingredient, unit: whole_unit, grams: 67)

        result = calculator.send(:convert_to_grams, 2, 'whole', 'lime', ingredient)
        expect(result).to eq(134)
      end

      it 'test 34: database conversion takes priority over hardcoded' do
        ingredient = create_ingredient_with_nutrition('eggs', calories: 143)
        whole_unit = Unit.find_or_create_by!(canonical_name: 'whole') { |u| u.category = 'unit_quantity' }
        create(:ingredient_unit_conversion, ingredient: ingredient, unit: whole_unit, grams: 55)

        result = calculator.send(:convert_to_grams, 4, 'whole', 'eggs', ingredient)
        expect(result).to eq(220)
      end

      it 'test 35: falls back to standard conversion when no db entry' do
        ingredient = create_ingredient_with_nutrition('flour', calories: 364)
        result = calculator.send(:convert_to_grams, 500, 'g', 'flour', ingredient)
        expect(result).to eq(500)
      end
    end

    context 'Edge cases' do
      it 'test 36: returns 0 for nil amount' do
        ingredient = create_ingredient_with_nutrition('salt', calories: 0)
        result = calculator.send(:convert_to_grams, nil, 'tsp', 'salt', ingredient)
        expect(result).to eq(0)
      end

      it 'test 37: returns 0 for zero amount' do
        ingredient = create_ingredient_with_nutrition('pepper', calories: 0)
        result = calculator.send(:convert_to_grams, 0, 'tsp', 'pepper', ingredient)
        expect(result).to eq(0)
      end

      it 'test 38: treats unknown unit as grams' do
        ingredient = create_ingredient_with_nutrition('spice mix', calories: 200)
        result = calculator.send(:convert_to_grams, 15, 'pinch', 'spice mix', ingredient)
        expect(result).to eq(15)
      end

      it 'test 39: handles plural unit normalization' do
        ingredient = create_ingredient_with_nutrition('eggs', calories: 143)
        result_plural = calculator.send(:convert_to_grams, 2, 'pieces', 'eggs', ingredient)
        result_singular = calculator.send(:convert_to_grams, 2, 'piece', 'eggs', ingredient)
        expect(result_plural).to eq(result_singular)
      end

      it 'test 40: handles unit normalization variations' do
        ingredient = create_ingredient_with_nutrition('flour', calories: 364)
        result_gram = calculator.send(:convert_to_grams, 100, 'gram', 'flour', ingredient)
        result_grams = calculator.send(:convert_to_grams, 100, 'grams', 'flour', ingredient)
        result_g = calculator.send(:convert_to_grams, 100, 'g', 'flour', ingredient)

        expect(result_gram).to eq(result_grams)
        expect(result_grams).to eq(result_g)
      end
    end
  end

  describe '#calculate' do
    it 'test 41: calculates total nutrition for a recipe' do
      recipe = create(:recipe, servings_original: 4)
      ingredient = recipe.ingredient_groups.first.recipe_ingredients.first.ingredient
      create(:ingredient_nutrition, ingredient: ingredient, calories: 200, protein_g: 25, carbs_g: 0, fat_g: 10, fiber_g: 0)

      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }
      recipe.ingredient_groups.first.recipe_ingredients.first.update!(amount: 500, unit: g_unit)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:total][:calories]).to be_within(1).of(1000)
      expect(result[:total][:protein_g]).to be_within(0.1).of(125)
    end

    it 'test 42: calculates per-serving nutrition' do
      recipe = create(:recipe, servings_original: 4)
      ingredient = recipe.ingredient_groups.first.recipe_ingredients.first.ingredient
      create(:ingredient_nutrition, ingredient: ingredient, calories: 200)

      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }
      recipe.ingredient_groups.first.recipe_ingredients.first.update!(amount: 500, unit: g_unit)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:per_serving][:calories]).to eq(250)
    end

    it 'test 43: handles per-serving calculation correctly' do
      recipe = create(:recipe, servings_original: 1)
      ingredient = recipe.ingredient_groups.first.recipe_ingredients.first.ingredient
      create(:ingredient_nutrition, ingredient: ingredient, calories: 100)

      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }
      recipe.ingredient_groups.first.recipe_ingredients.first.update!(amount: 100, unit: g_unit)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:per_serving][:calories]).to eq(100)
    end

    it 'test 44: rounds nutrition values appropriately' do
      recipe = create(:recipe, servings_original: 3)
      ingredient = recipe.ingredient_groups.first.recipe_ingredients.first.ingredient
      create(:ingredient_nutrition, ingredient: ingredient, calories: 133)

      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }
      recipe.ingredient_groups.first.recipe_ingredients.first.update!(amount: 100, unit: g_unit)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:per_serving][:calories]).to eq(44)
    end

    it 'test 45: uses default nutrition for unknown ingredients' do
      recipe = create(:recipe, servings_original: 1)
      # Don't create ingredient_nutrition - should use default

      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }
      recipe.ingredient_groups.first.recipe_ingredients.first.update!(amount: 100, unit: g_unit)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      # Default nutrition from NutritionLookupService::DEFAULT_NUTRITION
      expect(result[:per_serving][:calories]).to be >= 0
    end
  end

  describe 'Real-world recipe scenarios' do
    it 'test 46: Pad Thai style - noodles, shrimp, eggs' do
      recipe = create(:recipe, servings_original: 2)
      group = recipe.ingredient_groups.first
      group.recipe_ingredients.clear

      noodles = create_ingredient_with_nutrition('rice noodles', calories: 360)
      shrimp = create_ingredient_with_nutrition('shrimp', calories: 85)
      egg = create_ingredient_with_nutrition('eggs', calories: 143)

      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }
      whole_unit = Unit.find_or_create_by!(canonical_name: 'whole') { |u| u.category = 'unit_quantity' }

      group.recipe_ingredients.create!(ingredient: noodles, ingredient_name: 'rice noodles', amount: 200, unit: g_unit, position: 1)
      group.recipe_ingredients.create!(ingredient: shrimp, ingredient_name: 'shrimp', amount: 200, unit: g_unit, position: 2)
      group.recipe_ingredients.create!(ingredient: egg, ingredient_name: 'eggs', amount: 2, unit: whole_unit, position: 3)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:per_serving][:calories]).to be_between(500, 550)
    end

    it 'test 47: Pizza - flour, cheese, tomato sauce' do
      recipe = create(:recipe, servings_original: 4)
      group = recipe.ingredient_groups.first
      group.recipe_ingredients.clear

      flour = create_ingredient_with_nutrition('flour', calories: 364)
      cheese = create_ingredient_with_nutrition('mozzarella', calories: 280)
      tomato = create_ingredient_with_nutrition('tomato sauce', calories: 32)

      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }

      group.recipe_ingredients.create!(ingredient: flour, ingredient_name: 'flour', amount: 350, unit: g_unit, position: 1)
      group.recipe_ingredients.create!(ingredient: cheese, ingredient_name: 'mozzarella', amount: 200, unit: g_unit, position: 2)
      group.recipe_ingredients.create!(ingredient: tomato, ingredient_name: 'tomato sauce', amount: 150, unit: g_unit, position: 3)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:per_serving][:calories]).to be_between(400, 500)
    end

    it 'test 48: Salad with olive oil dressing' do
      recipe = create(:recipe, servings_original: 2)
      group = recipe.ingredient_groups.first
      group.recipe_ingredients.clear

      lettuce = create_ingredient_with_nutrition('lettuce', calories: 15)
      tomatoes = create_ingredient_with_nutrition('tomatoes', calories: 18)
      feta = create_ingredient_with_nutrition('feta', calories: 264)
      olive_oil = create_ingredient_with_nutrition('olive oil', calories: 884)

      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }
      tbsp_unit = Unit.find_or_create_by!(canonical_name: 'tbsp') { |u| u.category = 'unit_volume' }

      group.recipe_ingredients.create!(ingredient: lettuce, ingredient_name: 'lettuce', amount: 200, unit: g_unit, position: 1)
      group.recipe_ingredients.create!(ingredient: tomatoes, ingredient_name: 'tomatoes', amount: 150, unit: g_unit, position: 2)
      group.recipe_ingredients.create!(ingredient: feta, ingredient_name: 'feta', amount: 100, unit: g_unit, position: 3)
      group.recipe_ingredients.create!(ingredient: olive_oil, ingredient_name: 'olive oil', amount: 2, unit: tbsp_unit, position: 4)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:per_serving][:calories]).to be_between(250, 350)
    end

    it 'test 49: Soup with broth base' do
      recipe = create(:recipe, servings_original: 6)
      group = recipe.ingredient_groups.first
      group.recipe_ingredients.clear

      broth = create_ingredient_with_nutrition('chicken stock', calories: 9)
      onion = create_ingredient_with_nutrition('onion', calories: 40)
      carrot = create_ingredient_with_nutrition('carrots', calories: 41)

      l_unit = Unit.find_or_create_by!(canonical_name: 'l') { |u| u.category = 'unit_volume' }
      g_unit = Unit.find_or_create_by!(canonical_name: 'g') { |u| u.category = 'unit_weight' }

      group.recipe_ingredients.create!(ingredient: broth, ingredient_name: 'chicken stock', amount: 2, unit: l_unit, position: 1)
      group.recipe_ingredients.create!(ingredient: onion, ingredient_name: 'onion', amount: 200, unit: g_unit, position: 2)
      group.recipe_ingredients.create!(ingredient: carrot, ingredient_name: 'carrots', amount: 300, unit: g_unit, position: 3)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:per_serving][:calories]).to be_between(50, 80)
    end

    it 'test 50: Baking with flour cups (density conversion)' do
      recipe = create(:recipe, servings_original: 24)
      group = recipe.ingredient_groups.first
      group.recipe_ingredients.clear

      flour = create_ingredient_with_nutrition('all-purpose flour', calories: 364)
      sugar = create_ingredient_with_nutrition('sugar', calories: 387)
      butter = create_ingredient_with_nutrition('butter', calories: 717)

      cup_unit = Unit.find_or_create_by!(canonical_name: 'cup') { |u| u.category = 'unit_volume' }

      group.recipe_ingredients.create!(ingredient: flour, ingredient_name: 'all-purpose flour', amount: 2, unit: cup_unit, position: 1)
      group.recipe_ingredients.create!(ingredient: sugar, ingredient_name: 'sugar', amount: 1, unit: cup_unit, position: 2)
      group.recipe_ingredients.create!(ingredient: butter, ingredient_name: 'butter', amount: 1, unit: cup_unit, position: 3)

      calc = described_class.new(recipe.reload)
      result = calc.calculate

      expect(result[:per_serving][:calories]).to be_between(100, 180)
    end
  end

  describe '#normalize_unit' do
    let(:recipe) { create(:recipe) }
    let(:calculator) { described_class.new(recipe) }

    it 'normalizes gram variations' do
      expect(calculator.send(:normalize_unit, 'grams')).to eq('g')
      expect(calculator.send(:normalize_unit, 'gram')).to eq('g')
      expect(calculator.send(:normalize_unit, 'g')).to eq('g')
    end

    it 'normalizes tablespoon variations' do
      expect(calculator.send(:normalize_unit, 'tablespoons')).to eq('tbsp')
      expect(calculator.send(:normalize_unit, 'tablespoon')).to eq('tbsp')
      expect(calculator.send(:normalize_unit, 'tbsp')).to eq('tbsp')
    end

    it 'returns nil for blank input' do
      expect(calculator.send(:normalize_unit, nil)).to be_nil
      expect(calculator.send(:normalize_unit, '')).to be_nil
    end
  end
end
