class IngredientSearchService
  MIN_SIMILARITY = 0.3
  EXACT_THRESHOLD = 0.9

  def self.search(query, limit: 10)
    new.search(query, limit: limit)
  end

  def self.find_or_suggest(query)
    new.find_or_suggest(query)
  end

  def search(query, limit: 10)
    return [] if query.blank?

    normalized = normalize(query)

    exact = exact_canonical_match(normalized)
    return [exact] if exact

    alias_match = exact_alias_match(normalized)
    return [alias_match] if alias_match

    prefix_matches = prefix_search(normalized, limit)
    return prefix_matches if prefix_matches.any?

    trigram_search(normalized, limit)
  end

  def find_or_suggest(query)
    return { exact_match: nil, suggestions: [] } if query.blank?

    normalized = normalize(query)
    results = search(query, limit: 5)

    exact = results.first if results.first&.canonical_name&.downcase == normalized
    exact ||= find_by_alias(normalized)

    {
      exact_match: exact,
      suggestions: results
    }
  end

  private

  def normalize(query)
    query.to_s.strip.downcase.gsub(/\s+/, ' ')
  end

  def exact_canonical_match(normalized)
    Ingredient.where("LOWER(canonical_name) = ?", normalized).first
  end

  def exact_alias_match(normalized)
    IngredientAlias.where("LOWER(alias) = ?", normalized)
                   .includes(:ingredient)
                   .first&.ingredient
  end

  def find_by_alias(normalized)
    exact_alias_match(normalized)
  end

  def prefix_search(normalized, limit)
    canonical_matches = Ingredient
      .where("LOWER(canonical_name) LIKE ?", "#{sanitize_like(normalized)}%")
      .limit(limit)
      .to_a

    alias_matches = IngredientAlias
      .where("LOWER(alias) LIKE ?", "#{sanitize_like(normalized)}%")
      .includes(:ingredient)
      .limit(limit)
      .map(&:ingredient)

    (canonical_matches + alias_matches).uniq.first(limit)
  end

  def trigram_search(normalized, limit)
    canonical_results = Ingredient
      .select("ingredients.*, similarity(LOWER(canonical_name), #{quoted(normalized)}) AS sim")
      .where("similarity(LOWER(canonical_name), ?) > ?", normalized, MIN_SIMILARITY)
      .order("sim DESC")
      .limit(limit)
      .to_a

    alias_results = IngredientAlias
      .select("ingredient_aliases.*, similarity(LOWER(alias), #{quoted(normalized)}) AS sim")
      .where("similarity(LOWER(alias), ?) > ?", normalized, MIN_SIMILARITY)
      .includes(:ingredient)
      .order("sim DESC")
      .limit(limit)
      .map(&:ingredient)

    merged = (canonical_results + alias_results).uniq
    merged.sort_by { |i| -best_similarity(i, normalized) }.first(limit)
  end

  def best_similarity(ingredient, normalized)
    canonical_sim = pg_similarity(ingredient.canonical_name, normalized)
    alias_sims = ingredient.aliases.map { |a| pg_similarity(a.alias, normalized) }
    [canonical_sim, *alias_sims].max
  end

  def pg_similarity(text, normalized)
    result = ActiveRecord::Base.connection.execute(
      "SELECT similarity(#{quoted(text.downcase)}, #{quoted(normalized)}) AS sim"
    )
    result.first['sim'].to_f
  end

  def quoted(value)
    ActiveRecord::Base.connection.quote(value)
  end

  def sanitize_like(value)
    value.gsub(/[%_]/) { |char| "\\#{char}" }
  end
end
