class TranslateRecipeJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    translator = RecipeTranslator.new
    translations = {}

    RecipeTranslator::LANGUAGES.keys.each do |lang|
      translations[lang] = translator.translate_recipe(recipe, lang)
    end

    recipe.update!(
      translations: translations,
      translations_completed: true
    )
  rescue StandardError => e
    Rails.logger.error("Translation failed for recipe #{recipe_id}: #{e.message}")
    raise
  end
end
