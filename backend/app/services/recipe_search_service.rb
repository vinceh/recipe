# Recipe Search Service - Advanced search and filtering for recipes
class RecipeSearchService
  # AC-SEARCH-001: Fuzzy search with typo tolerance using Levenshtein distance
  # Searches for recipes with name similarity >85%
  def self.fuzzy_search(query, similarity_threshold: 0.85)
    return Recipe.none if query.blank?

    query_normalized = query.downcase.strip

    # Use PostgreSQL's similarity extension for fuzzy matching
    # First, try exact or ILIKE match
    exact_matches = Recipe.where("LOWER(name) LIKE ?", "%#{query_normalized}%")

    return exact_matches if exact_matches.any?

    # If no exact matches, use trigram similarity
    # This requires pg_trgm extension in PostgreSQL
    sanitized_order = ActiveRecord::Base.sanitize_sql_array(
      ["similarity(LOWER(name), ?) DESC", query_normalized]
    )
    Recipe.where("similarity(LOWER(name), ?) > ?", query_normalized, similarity_threshold)
          .order(Arel.sql(sanitized_order))
  end

  # AC-SEARCH-002: Search by recipe aliases
  def self.search_by_alias(query)
    return Recipe.none if query.blank?

    query_normalized = query.downcase.strip

    Recipe.joins(:recipe_aliases)
          .where("LOWER(recipe_aliases.alias_name) LIKE ?", "%#{query_normalized}%")
          .distinct
  end

  # AC-SEARCH-003: Ingredient-based search
  def self.search_by_ingredient(ingredient_name)
    return Recipe.none if ingredient_name.blank?

    ingredient_normalized = ingredient_name.downcase.strip

    Recipe.joins(ingredient_groups: :recipe_ingredients)
          .where("LOWER(recipe_ingredients.ingredient_name) LIKE ?", "%#{ingredient_normalized}%")
          .distinct
  end

  # Combined search across name, aliases, and ingredients
  def self.comprehensive_search(query)
    return Recipe.none if query.blank?

    # Try fuzzy name search first
    name_results = fuzzy_search(query, similarity_threshold: 0.85)
    return name_results if name_results.any?

    # Try alias search
    alias_results = search_by_alias(query)
    return alias_results if alias_results.any?

    # Try ingredient search as last resort
    search_by_ingredient(query)
  end

  # AC-SEARCH-004: Filter by calorie range
  def self.filter_by_calorie_range(recipes, min_calories: nil, max_calories: nil)
    recipes = recipes.all if recipes.is_a?(Class)
    return recipes unless min_calories.present? || max_calories.present?

    recipes = recipes.joins(:recipe_nutrition)
    recipes = recipes.where("recipe_nutrition.calories >= ?", min_calories.to_f) if min_calories.present?
    recipes = recipes.where("recipe_nutrition.calories <= ?", max_calories.to_f) if max_calories.present?
    recipes
  end

  # AC-SEARCH-005: Filter by minimum protein
  def self.filter_by_protein(recipes, min_protein: nil)
    return recipes if min_protein.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    recipes.joins(:recipe_nutrition)
           .where("recipe_nutrition.protein_g >= ?", min_protein.to_f)
  end

  # AC-SEARCH-006: Filter by maximum carbs
  def self.filter_by_carbs(recipes, max_carbs: nil)
    return recipes if max_carbs.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    recipes.joins(:recipe_nutrition)
           .where("recipe_nutrition.carbs_g <= ?", max_carbs.to_f)
  end

  # AC-SEARCH-007: Filter by maximum fat
  def self.filter_by_fat(recipes, max_fat: nil)
    return recipes if max_fat.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    recipes.joins(:recipe_nutrition)
           .where("recipe_nutrition.fat_g <= ?", max_fat.to_f)
  end

  # AC-SEARCH-008: Filter by multiple dietary tags (AND logic)
  def self.filter_by_dietary_tags_all(recipes, tags)
    return recipes if tags.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    tags = tags.split(',').map(&:strip) if tags.is_a?(String)

    recipes.joins(:dietary_tags)
           .where(data_references: { key: tags })
           .group('recipes.id')
           .having("COUNT(*) = ?", tags.size)
  end

  # AC-SEARCH-009: Filter by cuisine (supports multiple with OR logic)
  def self.filter_by_cuisines(recipes, cuisines)
    return recipes if cuisines.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    cuisines = cuisines.split(',').map(&:strip) if cuisines.is_a?(String)

    recipes.joins(:cuisines)
           .where(data_references: { key: cuisines })
           .distinct
  end

  # AC-SEARCH-010: Filter by dish type
  def self.filter_by_dish_types(recipes, dish_types)
    return recipes if dish_types.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    dish_types = dish_types.split(',').map(&:strip) if dish_types.is_a?(String)

    recipes.joins(:dish_types)
           .where(data_references: { key: dish_types })
           .distinct
  end

  # AC-SEARCH-011: Filter by recipe type
  def self.filter_by_recipe_types(recipes, recipe_types)
    return recipes if recipe_types.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    recipe_types = recipe_types.split(',').map(&:strip) if recipe_types.is_a?(String)

    recipes.joins(:recipe_types)
           .where(data_references: { key: recipe_types })
           .distinct
  end

  # AC-SEARCH-012: Filter by prep time
  def self.filter_by_prep_time(recipes, max_prep: nil)
    return recipes if max_prep.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    recipes.where("prep_minutes <= ?", max_prep.to_i)
  end

  # AC-SEARCH-013: Filter by cook time
  def self.filter_by_cook_time(recipes, max_cook: nil)
    return recipes if max_cook.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    recipes.where("cook_minutes <= ?", max_cook.to_i)
  end

  # AC-SEARCH-014: Filter by total time
  def self.filter_by_total_time(recipes, max_total: nil)
    return recipes if max_total.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    recipes.where("total_minutes <= ?", max_total.to_i)
  end

  # AC-SEARCH-015: Filter by serving size range
  def self.filter_by_servings(recipes, min_servings: nil, max_servings: nil)
    recipes = recipes.all if recipes.is_a?(Class)

    if min_servings.present?
      recipes = recipes.where("servings_original >= ?", min_servings.to_i)
    end

    if max_servings.present?
      recipes = recipes.where("servings_original <= ?", max_servings.to_i)
    end

    recipes
  end

  # AC-SEARCH-016: Exclude recipes with specific ingredients (allergen filtering)
  def self.exclude_ingredients(recipes, excluded_ingredients)
    return recipes if excluded_ingredients.blank?

    recipes = recipes.all if recipes.is_a?(Class)
    excluded_ingredients = excluded_ingredients.split(',').map(&:strip) if excluded_ingredients.is_a?(String)

    # Build OR conditions for all excluded ingredients in single query
    condition = excluded_ingredients.map { "LOWER(recipe_ingredients.ingredient_name) LIKE ?" }.join(" OR ")
    params = excluded_ingredients.map { |i| "%#{i.downcase}%" }

    excluded_recipe_ids = Recipe.joins(ingredient_groups: :recipe_ingredients)
                                 .where(condition, *params)
                                 .select(:id)
                                 .distinct

    recipes.where.not(id: excluded_recipe_ids)
  end

  # Combined advanced search with all filters
  def self.advanced_search(params = {})
    recipes = Recipe.all

    # Text search
    if params[:q].present?
      recipes = comprehensive_search(params[:q])
    end

    # Ingredient search
    if params[:ingredient].present?
      recipes = search_by_ingredient(params[:ingredient])
    end

    # Exclude ingredients (allergens)
    if params[:exclude_ingredients].present?
      recipes = exclude_ingredients(recipes, params[:exclude_ingredients])
    end

    # Nutrition filters
    recipes = filter_by_calorie_range(recipes,
      min_calories: params[:min_calories],
      max_calories: params[:max_calories]
    )
    recipes = filter_by_protein(recipes, min_protein: params[:min_protein])
    recipes = filter_by_carbs(recipes, max_carbs: params[:max_carbs])
    recipes = filter_by_fat(recipes, max_fat: params[:max_fat])

    # Category filters
    recipes = filter_by_dietary_tags_all(recipes, params[:dietary_tags]) if params[:dietary_tags].present?
    recipes = filter_by_cuisines(recipes, params[:cuisines]) if params[:cuisines].present?
    recipes = filter_by_dish_types(recipes, params[:dish_types]) if params[:dish_types].present?
    recipes = filter_by_recipe_types(recipes, params[:recipe_types]) if params[:recipe_types].present?

    # Time filters
    recipes = filter_by_prep_time(recipes, max_prep: params[:max_prep_time])
    recipes = filter_by_cook_time(recipes, max_cook: params[:max_cook_time])
    recipes = filter_by_total_time(recipes, max_total: params[:max_total_time])

    # Servings filter
    recipes = filter_by_servings(recipes,
      min_servings: params[:min_servings],
      max_servings: params[:max_servings]
    )

    recipes
  end
end
