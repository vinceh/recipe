class NutritionLookupJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    calculator = RecipeNutritionCalculator.new(recipe)

    nutrition_data = calculator.calculate

    recipe.update!(
      nutrition: {
        per_serving: nutrition_data[:per_serving],
        total: nutrition_data[:total]
      }
    )
  rescue StandardError => e
    Rails.logger.error("Nutrition calculation failed for recipe #{recipe_id}: #{e.message}")
    # Set default nutrition values
    recipe.update!(
      nutrition: {
        per_serving: { calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0, fiber_g: 0 }
      }
    )
  end
end
