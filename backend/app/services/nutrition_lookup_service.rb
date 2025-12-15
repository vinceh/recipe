class NutritionLookupService
  DEFAULT_NUTRITION = { calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0, fiber_g: 0 }.freeze

  def lookup_ingredient(ingredient_name, language = 'en')
    ingredient = find_in_database(ingredient_name, language)
    return format_nutrition(ingredient.nutrition) if ingredient&.nutrition

    DEFAULT_NUTRITION.dup
  end

  def find_ingredient(ingredient_name, language = 'en')
    find_in_database(ingredient_name, language)
  end

  private

  def find_in_database(name, language)
    normalized = normalize_ingredient_name(name)

    # 1. Exact canonical name match
    ingredient = Ingredient.find_by("LOWER(canonical_name) = ?", normalized.downcase)
    return ingredient if ingredient

    # 2. Exact alias match (prioritize same language)
    alias_match = IngredientAlias
      .where("LOWER(alias) = ?", normalized.downcase)
      .order(Arel.sql("CASE WHEN language = '#{language}' THEN 0 ELSE 1 END"))
      .first

    return alias_match.ingredient if alias_match

    # 3. Fuzzy match on canonical names using trigram similarity
    fuzzy_match = Ingredient
      .where("similarity(canonical_name, ?) > 0.4", normalized)
      .order(Arel.sql("similarity(canonical_name, '#{normalized.gsub("'", "''")}') DESC"))
      .first

    return fuzzy_match if fuzzy_match

    # 4. Fuzzy match on aliases
    alias_fuzzy = IngredientAlias
      .where("similarity(alias, ?) > 0.4", normalized)
      .order(Arel.sql("similarity(alias, '#{normalized.gsub("'", "''")}') DESC"))
      .first

    alias_fuzzy&.ingredient
  end

  def normalize_ingredient_name(name)
    name.to_s
        .downcase
        .gsub(/[^\w\s]/, '')
        .gsub(/\s+/, ' ')
        .strip
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
