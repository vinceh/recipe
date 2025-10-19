class NutritionLookupService
  def initialize
    @nutritionix_client = NutritionixClient.new
  end

  def lookup_ingredient(ingredient_name, language = 'en')
    # 1. Check database first
    ingredient = find_in_database(ingredient_name, language)
    return format_nutrition(ingredient.nutrition) if ingredient&.nutrition

    # 2. Fallback to Nutritionix API
    nutrition_data = fetch_from_nutritionix(ingredient_name)

    # 3. Store in database for future use
    if nutrition_data
      ingredient = store_ingredient(ingredient_name, nutrition_data, language, 'nutritionix')
      nutrition_data
    else
      # 4. Last resort: AI estimation (for obscure ingredients)
      ai_nutrition_data = estimate_with_ai(ingredient_name)
      store_ingredient(ingredient_name, ai_nutrition_data, language, 'ai', confidence: 0.7)
      ai_nutrition_data
    end
  end

  private

  def find_in_database(name, language)
    # Normalize input
    normalized = normalize_ingredient_name(name)

    # Try exact match first
    ingredient = Ingredient.find_by(canonical_name: normalized)
    return ingredient if ingredient

    # Try fuzzy match via aliases
    alias_match = IngredientAlias
      .where(language: language)
      .where('LOWER(alias) = ?', normalized.downcase)
      .first

    return alias_match.ingredient if alias_match

    # Try Levenshtein fuzzy match
    fuzzy_match_ingredient(normalized, language)
  end

  def fuzzy_match_ingredient(name, language)
    # Get all ingredients and aliases in the same language
    candidates = Ingredient
      .joins(:aliases)
      .where(ingredient_aliases: { language: language })
      .select('ingredients.*, ingredient_aliases.alias')

    # Calculate similarity for each candidate
    best_match = nil
    best_score = 0.0

    candidates.each do |candidate|
      similarity = calculate_similarity(name, candidate.alias)

      if similarity > 0.85 && similarity > best_score
        best_match = candidate
        best_score = similarity
      end
    end

    best_match
  end

  def fetch_from_nutritionix(ingredient_name)
    response = @nutritionix_client.natural_language_search("100g #{ingredient_name}")

    return nil unless response['foods']&.any?

    food = response['foods'].first

    # Normalize to per 100g
    serving_weight_g = food['serving_weight_grams'] || 100
    factor = 100.0 / serving_weight_g

    {
      calories: (food['nf_calories'] * factor).round(1),
      protein_g: (food['nf_protein'] * factor).round(1),
      carbs_g: (food['nf_total_carbohydrate'] * factor).round(1),
      fat_g: (food['nf_total_fat'] * factor).round(1),
      fiber_g: (food['nf_dietary_fiber'] * factor).round(1)
    }
  rescue NutritionixClient::Error => e
    Rails.logger.error("Nutritionix API Error: #{e.message}")
    nil
  end

  def estimate_with_ai(ingredient_name)
    # Use Claude API to estimate nutrition
    # This is a FALLBACK for rare ingredients not in Nutritionix
    system_prompt = AiPrompt.active.find_by(prompt_key: 'nutrition_estimation_system')
    user_prompt = AiPrompt.active.find_by(prompt_key: 'nutrition_estimation')

    return fallback_defaults unless system_prompt && user_prompt

    rendered_user_prompt = user_prompt.render(ingredient_name: ingredient_name)

    ai_service = AiService.new
    response = ai_service.call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 512
    )

    # Extract JSON from response
    json_match = response.match(/```json\s*(\{.*?\})\s*```/m) || response.match(/(\{.*\})/m)
    return fallback_defaults unless json_match

    parsed = JSON.parse(json_match[1], symbolize_names: true)
    {
      calories: parsed[:calories].to_f,
      protein_g: parsed[:protein_g].to_f,
      carbs_g: parsed[:carbs_g].to_f,
      fat_g: parsed[:fat_g].to_f,
      fiber_g: parsed[:fiber_g].to_f
    }
  rescue JSON::ParserError, StandardError => e
    Rails.logger.error("AI nutrition estimation failed: #{e.message}")
    fallback_defaults
  end

  def fallback_defaults
    { calories: 100, protein_g: 2, carbs_g: 15, fat_g: 2, fiber_g: 1 }
  end

  def store_ingredient(name, nutrition_data, language, source, confidence: 1.0)
    normalized = normalize_ingredient_name(name)

    ingredient = Ingredient.find_or_create_by!(canonical_name: normalized) do |i|
      i.category = guess_category(name)
    end

    # Store nutrition data (only if not exists)
    unless ingredient.nutrition
      ingredient.create_nutrition!(
        calories: nutrition_data[:calories],
        protein_g: nutrition_data[:protein_g],
        carbs_g: nutrition_data[:carbs_g],
        fat_g: nutrition_data[:fat_g],
        fiber_g: nutrition_data[:fiber_g],
        data_source: source,
        confidence_score: confidence
      )
    end

    # Create alias for the input name (if different from canonical)
    unless normalized == name.downcase
      ingredient.aliases.find_or_create_by!(
        alias: name,
        language: language,
        alias_type: 'synonym'
      )
    end

    ingredient
  end

  def normalize_ingredient_name(name)
    name.downcase
        .gsub(/[^\w\s]/, '')  # Remove punctuation
        .gsub(/\s+/, ' ')      # Normalize whitespace
        .strip
        .singularize           # "tomatoes" → "tomato"
  end

  def guess_category(name)
    # Simple heuristic-based categorization
    vegetables = ['carrot', 'tomato', 'onion', 'pepper', 'lettuce']
    proteins = ['chicken', 'beef', 'pork', 'fish', 'tofu', 'egg']
    grains = ['rice', 'wheat', 'oat', 'quinoa', 'pasta']
    dairy = ['milk', 'cheese', 'yogurt', 'cream', 'butter']

    normalized = name.downcase

    return 'vegetable' if vegetables.any? { |v| normalized.include?(v) }
    return 'protein' if proteins.any? { |p| normalized.include?(p) }
    return 'grain' if grains.any? { |g| normalized.include?(g) }
    return 'dairy' if dairy.any? { |d| normalized.include?(d) }

    'other'
  end

  def calculate_similarity(str1, str2)
    # Levenshtein distance ratio using damerau-levenshtein gem
    max_len = [str1.length, str2.length].max
    return 1.0 if max_len.zero?

    distance = DamerauLevenshtein.distance(str1, str2)
    1.0 - (distance.to_f / max_len)
  end

  def format_nutrition(nutrition)
    {
      calories: nutrition.calories,
      protein_g: nutrition.protein_g,
      carbs_g: nutrition.carbs_g,
      fat_g: nutrition.fat_g,
      fiber_g: nutrition.fiber_g
    }
  end
end
