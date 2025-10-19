class RecipeNutritionCalculator
  def initialize(recipe)
    @recipe = recipe
    @lookup_service = NutritionLookupService.new
  end

  def calculate
    total_nutrition = {
      calories: 0,
      protein_g: 0,
      carbs_g: 0,
      fat_g: 0,
      fiber_g: 0
    }

    @recipe.ingredient_groups.each do |group|
      group['items'].each do |ingredient|
        ingredient_nutrition = calculate_ingredient_nutrition(ingredient)

        total_nutrition[:calories] += ingredient_nutrition[:calories]
        total_nutrition[:protein_g] += ingredient_nutrition[:protein_g]
        total_nutrition[:carbs_g] += ingredient_nutrition[:carbs_g]
        total_nutrition[:fat_g] += ingredient_nutrition[:fat_g]
        total_nutrition[:fiber_g] += ingredient_nutrition[:fiber_g]
      end
    end

    # Calculate per serving
    servings = @recipe.servings['original']
    per_serving = {
      calories: (total_nutrition[:calories] / servings).round,
      protein_g: (total_nutrition[:protein_g] / servings).round(1),
      carbs_g: (total_nutrition[:carbs_g] / servings).round(1),
      fat_g: (total_nutrition[:fat_g] / servings).round(1),
      fiber_g: (total_nutrition[:fiber_g] / servings).round(1)
    }

    {
      total: total_nutrition,
      per_serving: per_serving
    }
  end

  private

  def calculate_ingredient_nutrition(ingredient)
    name = ingredient['name']
    amount = ingredient['amount'].to_f
    unit = ingredient['unit']

    # Lookup nutrition data (database → API → AI)
    nutrition_per_100g = @lookup_service.lookup_ingredient(name, @recipe.language)

    # Convert ingredient amount to grams
    grams = convert_to_grams(amount, unit, name)

    # Calculate nutrition for this specific amount
    {
      calories: (nutrition_per_100g[:calories] * grams / 100).round(1),
      protein_g: (nutrition_per_100g[:protein_g] * grams / 100).round(1),
      carbs_g: (nutrition_per_100g[:carbs_g] * grams / 100).round(1),
      fat_g: (nutrition_per_100g[:fat_g] * grams / 100).round(1),
      fiber_g: (nutrition_per_100g[:fiber_g] * grams / 100).round(1)
    }
  end

  def convert_to_grams(amount, unit, ingredient_name)
    # Use conversion logic for volume → weight conversions
    case unit
    when 'g', 'gram', 'grams'
      amount
    when 'kg', 'kilogram', 'kilograms'
      amount * 1000
    when 'oz', 'ounce', 'ounces'
      amount * 28.35
    when 'lb', 'pound', 'pounds'
      amount * 453.592
    when 'cup', 'cups'
      estimate_grams_from_volume(ingredient_name, amount, 'cup')
    when 'tbsp', 'tablespoon', 'tablespoons'
      estimate_grams_from_volume(ingredient_name, amount, 'tbsp')
    when 'tsp', 'teaspoon', 'teaspoons'
      estimate_grams_from_volume(ingredient_name, amount, 'tsp')
    when 'ml', 'milliliter', 'milliliters'
      estimate_grams_from_ml(ingredient_name, amount)
    when 'l', 'liter', 'liters'
      estimate_grams_from_ml(ingredient_name, amount * 1000)
    when 'whole', 'piece', 'pieces', 'item', 'items'
      estimate_grams_from_count(ingredient_name, amount)
    else
      # Default assumption: treat as grams
      amount
    end
  end

  def estimate_grams_from_volume(ingredient_name, amount, unit)
    # Convert to ml first
    ml = case unit
    when 'cup'
      amount * 240
    when 'tbsp'
      amount * 15
    when 'tsp'
      amount * 5
    else
      amount
    end

    estimate_grams_from_ml(ingredient_name, ml)
  end

  def estimate_grams_from_ml(ingredient_name, ml)
    # Estimate density based on ingredient type
    normalized = ingredient_name.downcase

    density_g_per_ml = case
    when normalized.include?('water') || normalized.include?('stock') || normalized.include?('broth')
      1.0
    when normalized.include?('milk') || normalized.include?('cream')
      1.03
    when normalized.include?('oil') || normalized.include?('butter')
      0.92
    when normalized.include?('honey') || normalized.include?('syrup')
      1.4
    when normalized.include?('flour')
      0.5
    when normalized.include?('sugar')
      0.85
    when normalized.include?('rice')
      0.75
    else
      1.0  # Default to water density
    end

    ml * density_g_per_ml
  end

  def estimate_grams_from_count(ingredient_name, count)
    # Estimate weight for common whole items
    normalized = ingredient_name.downcase

    weight_per_item = case
    when normalized.include?('egg')
      50
    when normalized.include?('chicken breast')
      150
    when normalized.include?('onion')
      150
    when normalized.include?('tomato')
      100
    when normalized.include?('potato')
      150
    when normalized.include?('carrot')
      60
    when normalized.include?('apple')
      150
    when normalized.include?('banana')
      120
    else
      100  # Default assumption
    end

    count * weight_per_item
  end
end
