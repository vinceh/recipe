class TranslateRecipeJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe
      .includes(ingredient_groups: :recipe_ingredients)
      .includes(:recipe_steps, :equipment)
      .find(recipe_id)

    translator = RecipeTranslator.new
    all_successful = true

    target_languages = RecipeTranslator::LANGUAGES.keys.reject { |lang| lang == recipe.source_language }

    target_languages.each do |lang|
      begin
        translation_data = translator.translate_recipe(recipe, lang)
        apply_translations(recipe, translation_data, lang) if translation_data
      rescue StandardError => e
        Rails.logger.error("Translation failed for recipe #{recipe_id} language #{lang}: #{e.message}")
        all_successful = false
      end
    end

    if all_successful
      recipe.update!(translations_completed: true, last_translated_at: Time.current)
    else
      recipe.update!(translations_completed: false)
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Recipe not found for translation job #{recipe_id}: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Unexpected error in translation job for recipe #{recipe_id}: #{e.message}")
    raise
  end

  private

  def apply_translations(recipe, translation_data, locale)
    I18n.with_locale(locale) do
      # Update recipe name
      recipe.update(name: translation_data['name']) if translation_data['name']

      # Update ingredient groups and their ingredients
      if translation_data['ingredient_groups'].present?
        recipe.ingredient_groups.each_with_index do |group, idx|
          group_data = translation_data['ingredient_groups'][idx]
          next unless group_data

          group.update(name: group_data['name']) if group_data['name']

          # Update ingredients within the group
          if group_data['items'].present?
            group.recipe_ingredients.each_with_index do |ingredient, item_idx|
              item_data = group_data['items'][item_idx]
              next unless item_data

              ingredient.update(
                ingredient_name: item_data['name'],
                preparation_notes: item_data['preparation']
              )
            end
          end
        end
      end

      # Update recipe steps
      if translation_data['steps'].present?
        recipe.recipe_steps.order(:step_number).each_with_index do |step, idx|
          step_data = translation_data['steps'][idx]
          next unless step_data

          step.update(instruction_original: step_data['instruction']) if step_data['instruction']
        end
      end

      # Update equipment
      if translation_data['equipment'].present?
        recipe.equipment.each_with_index do |equipment, idx|
          equipment_name = translation_data['equipment'][idx]
          equipment.update(canonical_name: equipment_name) if equipment_name
        end
      end
    end
  end
end
