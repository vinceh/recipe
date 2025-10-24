Rails.application.config.recipe = {
  translation_rate_limit: {
    max_translations_per_window: ENV.fetch('RECIPE_TRANSLATION_MAX_PER_HOUR', 4).to_i,
    rate_limit_window: ENV.fetch('RECIPE_TRANSLATION_RATE_LIMIT_WINDOW', 3600).to_i
  }
}
