class RecipeTranslator < AiService
  LANGUAGES = {
    'ja' => 'Japanese',
    'ko' => 'Korean',
    'zh-tw' => 'Traditional Chinese (Taiwan)',
    'zh-cn' => 'Simplified Chinese (China)',
    'es' => 'Spanish',
    'fr' => 'French'
  }.freeze

  def translate_recipe(recipe, target_language)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_translation_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_translation_user')

    lang_name = LANGUAGES[target_language]
    raise ArgumentError, "Unsupported language: #{target_language}" unless lang_name

    recipe_json = build_recipe_json_for_translation(recipe)

    rendered_user_prompt = user_prompt.render(
      target_language: lang_name,
      recipe_json: recipe_json
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096
    )

    parse_translation_response(response, target_language)
  end

  private

  def build_recipe_json_for_translation(recipe)
    {
      name: recipe.name,
      ingredient_groups: recipe.ingredient_groups.includes(:recipe_ingredients).map do |group|
        {
          name: group.name,
          items: group.recipe_ingredients.map do |ingredient|
            {
              name: ingredient.ingredient_name,
              amount: ingredient.amount,
              unit: ingredient.unit,
              preparation: ingredient.preparation_notes
            }
          end
        }
      end,
      steps: recipe.recipe_steps.order(:step_number).map do |step|
        {
          order: step.step_number,
          instructions: {
            original: step.instruction_original,
            easier: step.instruction_easier,
            no_equipment: step.instruction_no_equipment
          }
        }
      end,
      equipment: recipe.equipment.map(&:canonical_name)
    }.to_json
  end

  def parse_translation_response(response, language)
    # Extract JSON from response (may be wrapped in markdown code blocks)
    json_match = response.match(/```json\s*(\{.*?\})\s*```/m) || response.match(/(\{.*\})/m)
    return nil unless json_match

    JSON.parse(json_match[1])
  rescue JSON::ParserError => e
    Rails.logger.error("Translation parsing failed for #{language}: #{e.message}")
    nil
  end
end
