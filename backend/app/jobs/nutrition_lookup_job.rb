class NutritionLookupJob < ApplicationJob
  queue_as :default

  RATE_LIMIT_DELAY = 0.25

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    calculator = RecipeNutritionCalculator.new(recipe)

    nutrition_data = calculator.calculate

    if recipe.recipe_nutrition
      recipe.recipe_nutrition.update!(
        calories: nutrition_data[:per_serving][:calories],
        protein_g: nutrition_data[:per_serving][:protein_g],
        carbs_g: nutrition_data[:per_serving][:carbs_g],
        fat_g: nutrition_data[:per_serving][:fat_g]
      )
    else
      recipe.create_recipe_nutrition!(
        calories: nutrition_data[:per_serving][:calories],
        protein_g: nutrition_data[:per_serving][:protein_g],
        carbs_g: nutrition_data[:per_serving][:carbs_g],
        fat_g: nutrition_data[:per_serving][:fat_g]
      )
    end

    Rails.logger.info("Nutrition calculated for recipe #{recipe_id}: #{nutrition_data[:per_serving]}")
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Recipe #{recipe_id} not found for nutrition calculation")
  rescue StandardError => e
    Rails.logger.error("Nutrition calculation failed for recipe #{recipe_id}: #{e.message}")
    Rails.logger.error(e.backtrace.first(5).join("\n"))
  end
end
