class RecipeNutritionCalculator
  def initialize(recipe)
    @recipe = recipe
    @lookup_service = NutritionLookupService.new
  end

  def calculate
    total_nutrition = { calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0, fiber_g: 0 }

    @recipe.ingredient_groups.includes(recipe_ingredients: [{ ingredient: :nutrition }, :unit]).each do |group|
      group.recipe_ingredients.each do |recipe_ingredient|
        ingredient_nutrition = calculate_ingredient_nutrition(recipe_ingredient)

        total_nutrition[:calories] += ingredient_nutrition[:calories]
        total_nutrition[:protein_g] += ingredient_nutrition[:protein_g]
        total_nutrition[:carbs_g] += ingredient_nutrition[:carbs_g]
        total_nutrition[:fat_g] += ingredient_nutrition[:fat_g]
        total_nutrition[:fiber_g] += ingredient_nutrition[:fiber_g]
      end
    end

    servings = [@recipe.servings_original, 1].max
    per_serving = {
      calories: (total_nutrition[:calories] / servings).round,
      protein_g: (total_nutrition[:protein_g] / servings).round(1),
      carbs_g: (total_nutrition[:carbs_g] / servings).round(1),
      fat_g: (total_nutrition[:fat_g] / servings).round(1),
      fiber_g: (total_nutrition[:fiber_g] / servings).round(1)
    }

    { total: total_nutrition, per_serving: per_serving }
  end

  private

  def calculate_ingredient_nutrition(recipe_ingredient)
    name = recipe_ingredient.ingredient_name
    amount = recipe_ingredient.amount.to_f
    unit = recipe_ingredient.unit&.canonical_name

    # Use direct association if available, otherwise lookup by name
    ingredient = recipe_ingredient.ingredient || @lookup_service.find_ingredient(name, @recipe.source_language)
    nutrition_per_100g = if ingredient&.nutrition
                           format_nutrition(ingredient.nutrition)
                         else
                           NutritionLookupService::DEFAULT_NUTRITION.dup
                         end

    grams = convert_to_grams(amount, unit, name, ingredient)

    {
      calories: (nutrition_per_100g[:calories] * grams / 100).round(1),
      protein_g: (nutrition_per_100g[:protein_g] * grams / 100).round(1),
      carbs_g: (nutrition_per_100g[:carbs_g] * grams / 100).round(1),
      fat_g: (nutrition_per_100g[:fat_g] * grams / 100).round(1),
      fiber_g: (nutrition_per_100g[:fiber_g] * grams / 100).round(1)
    }
  end

  def convert_to_grams(amount, unit, ingredient_name, ingredient = nil)
    return 0.0 if amount.nil? || amount.zero?

    normalized_unit = normalize_unit(unit)

    # 1. Try database unit conversion first (most accurate)
    if ingredient
      db_grams = lookup_unit_conversion(ingredient, normalized_unit, amount)
      return db_grams if db_grams
    end

    # 2. Fall back to standard conversions
    case normalized_unit
    when 'g', 'gram'
      amount
    when 'kg'
      amount * 1000
    when 'oz'
      amount * 28.35
    when 'lb'
      amount * 453.592
    when 'cup'
      estimate_grams_from_volume(ingredient_name, amount, 240)
    when 'tbsp'
      estimate_grams_from_volume(ingredient_name, amount, 15)
    when 'tsp'
      estimate_grams_from_volume(ingredient_name, amount, 5)
    when 'ml'
      estimate_grams_from_ml(ingredient_name, amount)
    when 'l'
      estimate_grams_from_ml(ingredient_name, amount * 1000)
    when 'piece', 'whole', 'item', nil
      estimate_grams_from_count(ingredient_name, amount)
    else
      # Unknown unit, assume grams
      amount
    end
  end

  def normalize_unit(unit)
    return nil if unit.blank?

    unit_str = unit.to_s.downcase.strip

    unit_map = {
      'grams' => 'g', 'gram' => 'g',
      'kilograms' => 'kg', 'kilogram' => 'kg',
      'ounces' => 'oz', 'ounce' => 'oz',
      'pounds' => 'lb', 'pound' => 'lb',
      'cups' => 'cup',
      'tablespoons' => 'tbsp', 'tablespoon' => 'tbsp',
      'teaspoons' => 'tsp', 'teaspoon' => 'tsp',
      'milliliters' => 'ml', 'milliliter' => 'ml',
      'liters' => 'l', 'liter' => 'l',
      'pieces' => 'piece', 'items' => 'item'
    }

    unit_map[unit_str] || unit_str
  end

  def lookup_unit_conversion(ingredient, unit, amount)
    return nil unless ingredient && unit

    conversion = ingredient.unit_conversions.joins(:unit).find_by(
      units: { canonical_name: unit }
    )

    return nil unless conversion

    conversion.grams * amount
  end

  def estimate_grams_from_volume(ingredient_name, amount, ml_per_unit)
    ml = amount * ml_per_unit
    estimate_grams_from_ml(ingredient_name, ml)
  end

  def estimate_grams_from_ml(ingredient_name, ml)
    normalized = ingredient_name.to_s.downcase

    density = if normalized.include?('water') || normalized.include?('stock') || normalized.include?('broth')
                1.0
              elsif normalized.include?('milk') || normalized.include?('cream')
                1.03
              elsif normalized.include?('oil') || normalized.include?('butter')
                0.92
              elsif normalized.include?('honey') || normalized.include?('syrup')
                1.4
              elsif normalized.include?('flour')
                0.5
              elsif normalized.include?('sugar')
                0.85
              elsif normalized.include?('rice')
                0.75
              else
                1.0
              end

    ml * density
  end

  def estimate_grams_from_count(ingredient_name, count)
    normalized = ingredient_name.to_s.downcase

    weight = if normalized.include?('egg')
               50
             elsif normalized.include?('chicken breast')
               150
             elsif normalized.include?('onion')
               150
             elsif normalized.include?('tomato')
               100
             elsif normalized.include?('potato')
               150
             elsif normalized.include?('carrot')
               60
             elsif normalized.include?('apple')
               150
             elsif normalized.include?('banana')
               120
             elsif normalized.include?('garlic')
               5
             else
               100
             end

    count * weight
  end

  def format_nutrition(nutrition)
    {
      calories: nutrition.calories.to_f,
      protein_g: nutrition.protein_g.to_f,
      carbs_g: nutrition.carbs_g.to_f,
      fat_g: nutrition.fat_g.to_f,
      fiber_g: nutrition.fiber_g.to_f
    }
  end
end
