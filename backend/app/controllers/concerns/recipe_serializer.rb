module RecipeSerializer
  extend ActiveSupport::Concern

  private

  def serialize_ingredient_groups(recipe, include_canonical: false)
    recipe.ingredient_groups.map do |group|
      {
        name: group.name,
        items: group.recipe_ingredients.map do |item|
          result = {
            name: item.ingredient_name,
            amount: format_amount(item.amount),
            unit: include_canonical ? item.unit&.canonical_name : item.unit&.name,
            preparation: item.preparation_notes,
            optional: item.optional
          }
          result
        end
      }
    end
  end

  def serialize_recipe_steps(recipe)
    recipe.recipe_steps.map do |step|
      {
        id: "step-#{step.step_number.to_s.rjust(3, '0')}",
        order: step.step_number,
        instruction: step.instruction_original,
        section_heading: step.section_heading
      }
    end
  end

  def serialize_step_images(recipe)
    recipe.recipe_step_images.map do |img|
      {
        id: img.id,
        position: img.position.to_f,
        caption: img.caption,
        ai_generated: img.ai_generated,
        url: img.image.attached? ? rails_blob_url(img.image, only_path: false) : nil
      }
    end
  end

  def serialize_instruction_items(recipe)
    recipe.instruction_items.map do |item|
      result = {
        id: item.id,
        item_type: item.item_type,
        position: item.position,
        content: item.content
      }
      if item.image? && item.image.attached?
        result[:image_url] = rails_blob_url(item.image, only_path: false)
      end
      result
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
