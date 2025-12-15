class RecipeScaler
  FRIENDLY_FRACTIONS = {
    0.125 => '1/8',
    0.25 => '1/4',
    0.33 => '1/3',
    0.5 => '1/2',
    0.66 => '2/3',
    0.75 => '3/4'
  }.freeze

  def initialize(recipe)
    @recipe = recipe
    @context = detect_cooking_context(recipe)
  end

  def scale_by_servings(target_servings)
    scaling_factor = target_servings.to_f / @recipe.servings_original
    scale_all_ingredients(scaling_factor)
  end

  def scale_by_ingredient(ingredient_id, target_amount, target_unit)
    base_ingredient = find_ingredient_by_id(ingredient_id)
    return nil unless base_ingredient

    # Convert target to same unit as base
    converted_amount = UnitConverter.convert(
      target_amount,
      target_unit,
      base_ingredient.unit&.canonical_name
    )

    scaling_factor = converted_amount / (base_ingredient.amount || 1).to_f
    scale_all_ingredients(scaling_factor)
  end

  private

  def scale_all_ingredients(factor)
    scaled_groups = @recipe.ingredient_groups.map do |group|
      scaled_items = group.recipe_ingredients.map do |ingredient|
        scale_ingredient_copy(ingredient, factor)
      end
      {
        name: group.name,
        items: scaled_items
      }
    end

    {
      ingredient_groups: scaled_groups,
      scaled_servings: (@recipe.servings_original * factor).round(1)
    }
  end

  def scale_ingredient_copy(ingredient, factor)
    raw_amount = (ingredient.amount || 0).to_f * factor
    unit_name = ingredient.unit&.canonical_name

    if @context == 'baking'
      result = preserve_precision(raw_amount, unit_name)
      if result.is_a?(Hash)
        scaled_amount = result[:amount]
        unit_name = result[:unit]
      else
        scaled_amount = result
      end
    else
      scaled_amount = round_to_friendly_fraction(raw_amount)
      new_unit = step_down_unit(scaled_amount, unit_name)
      unit_name = new_unit
    end

    result_hash = {
      name: ingredient.ingredient_name,
      amount: scaled_amount.to_s,
      unit: unit_name,
      preparation: ingredient.preparation_notes.presence
    }.compact

    result_hash
  end

  def step_down_unit(amount, unit)
    numeric_amount = amount.is_a?(String) ? parse_friendly_fraction(amount) : amount.to_f

    if unit == 'tbsp' && numeric_amount < 1
      'tsp'
    elsif unit == 'cup' && numeric_amount < 0.25
      'tbsp'
    else
      unit
    end
  end

  def round_to_friendly_fraction(amount)
    # Try whole number first
    if (amount - amount.round).abs < 0.1
      return amount.round
    end

    # Try simple fraction
    FRIENDLY_FRACTIONS.each do |decimal, fraction|
      diff = (amount - decimal).abs
      return fraction if diff < 0.05
    end

    # Try mixed number (e.g., 1 1/2)
    if amount > 1
      whole_part = amount.floor
      fractional_part = amount - whole_part

      FRIENDLY_FRACTIONS.each do |decimal, fraction|
        if (fractional_part - decimal).abs < 0.05
          return "#{whole_part} #{fraction}"
        end
      end
    end

    # Fallback to 1 decimal place
    amount.round(1)
  end

  def preserve_precision(amount, unit)
    # For baking, convert small amounts to grams for precision
    if unit.in?(['cup', 'tbsp', 'tsp']) && amount < 0.25
      # Try to convert to grams
      # First convert to ml, then assume 1ml ≈ 1g for dry ingredients
      ml = UnitConverter.convert(amount, unit, 'ml')
      if ml > 0
        return { amount: ml.round(1), unit: 'g' }
      end
    end

    amount.round(2) # Keep 2 decimal places for baking
  end

  def parse_friendly_fraction(fraction_str)
    # Parse strings like "1 1/2", "1/2", "3/4" back to decimals
    return fraction_str.to_f if fraction_str.is_a?(Numeric)

    parts = fraction_str.to_s.strip.split(' ')
    if parts.length == 2
      # Mixed number like "1 1/2"
      whole = parts[0].to_f
      frac_parts = parts[1].split('/')
      whole + (frac_parts[0].to_f / frac_parts[1].to_f)
    elsif fraction_str.include?('/')
      # Simple fraction like "1/2"
      frac_parts = fraction_str.split('/')
      frac_parts[0].to_f / frac_parts[1].to_f
    else
      fraction_str.to_f
    end
  end

  def detect_cooking_context(recipe)
    # Use requires_precision flag to determine cooking context
    recipe.requires_precision ? 'baking' : 'cooking'
  end

  def find_ingredient_by_id(ingredient_id)
    @recipe.recipe_ingredients.find_by(id: ingredient_id)
  end
end
