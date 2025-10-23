module RecipeSerializer
  extend ActiveSupport::Concern

  private

  def serialize_ingredient_groups(recipe)
    recipe.ingredient_groups.map do |group|
      {
        name: group.name,
        items: group.recipe_ingredients.map do |item|
          {
            name: item.ingredient_name,
            amount: format_amount(item.amount),
            unit: item.unit,
            preparation: item.preparation_notes,
            optional: item.optional
          }
        end
      }
    end
  end

  def serialize_recipe_steps(recipe)
    recipe.recipe_steps.order(:step_number).map do |step|
      {
        id: "step-#{step.step_number.to_s.rjust(3, '0')}",
        order: step.step_number,
        instructions: {
          original: step.instruction_original,
          easier: step.instruction_easier,
          no_equipment: step.instruction_no_equipment
        }.compact
      }
    end
  end

  def serialize_nutrition(nutrition)
    {
      per_serving: {
        calories: nutrition.calories,
        protein_g: nutrition.protein_g,
        carbs_g: nutrition.carbs_g,
        fat_g: nutrition.fat_g,
        fiber_g: nutrition.fiber_g,
        sodium_mg: nutrition.sodium_mg,
        sugar_g: nutrition.sugar_g
      }.compact
    }
  end

  def format_amount(amount)
    return amount.to_s if amount.nil?

    if amount == amount.to_i
      amount.to_i.to_s
    else
      amount.to_s
    end
  end
end
