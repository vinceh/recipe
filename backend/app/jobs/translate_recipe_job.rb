class TranslateRecipeJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    translator = RecipeTranslator.new

    RecipeTranslator::LANGUAGES.keys.each do |lang|
      translation_data = translator.translate_recipe(recipe, lang)
      apply_translations(recipe, translation_data, lang) if translation_data
    end

    recipe.update!(translations_completed: true)
  rescue StandardError => e
    Rails.logger.error("Translation failed for recipe #{recipe_id}: #{e.message}")
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

          instructions = step_data['instructions']
          if instructions
            step.update(
              instruction_original: instructions['original'],
              instruction_easier: instructions['easier'],
              instruction_no_equipment: instructions['no_equipment']
            )
          end
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
