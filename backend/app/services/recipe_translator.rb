class RecipeTranslator < AiService
  LANGUAGES = {
    'ja' => 'Japanese',
    'ko' => 'Korean',
    'zh-tw' => 'Traditional Chinese (Taiwan)',
    'zh-cn' => 'Simplified Chinese (China)',
    'es' => 'Spanish',
    'fr' => 'French'
  }.freeze

  TRANSLATION_SCHEMA = {
    type: 'object',
    required: ['name', 'description', 'ingredient_groups', 'steps'],
    properties: {
      name: {
        type: 'string',
        description: 'Translated recipe name'
      },
      description: {
        type: 'string',
        description: 'Translated recipe description'
      },
      ingredient_groups: {
        type: 'array',
        items: {
          type: 'object',
          required: ['name', 'items'],
          properties: {
            name: { type: 'string', description: 'Translated group name' },
            items: {
              type: 'array',
              items: {
                type: 'object',
                required: ['name'],
                properties: {
                  name: { type: 'string', description: 'Translated ingredient name' },
                  amount: { type: 'string', description: 'Amount (keep unchanged)' },
                  unit: { type: 'string', description: 'Unit (translate measurement names)' },
                  preparation: { type: 'string', description: 'Translated preparation notes' }
                }
              }
            }
          }
        }
      },
      steps: {
        type: 'array',
        items: {
          type: 'object',
          required: ['order', 'instruction'],
          properties: {
            order: { type: 'integer', description: 'Step number (keep unchanged)' },
            instruction: { type: 'string', description: 'Translated instruction text' }
          }
        }
      },
      equipment: {
        type: 'array',
        items: { type: 'string' },
        description: 'Translated equipment names'
      }
    }
  }.freeze

  SYSTEM_PROMPT = <<~PROMPT
    You are a professional translator specializing in recipe translation with deep cultural knowledge of food terminology across languages.

    Key principles:
    1. For ingredients native to the target language's culture, use the authentic native term without explanation
    2. For foreign ingredients, provide transliteration plus a brief explanation in the target language if helpful
    3. Translate cooking techniques using proper culinary terminology for the target language
    4. Keep ALL numeric values unchanged (amounts, step numbers)
    5. Translate measurement units appropriately (e.g., "cups" → "カップ" in Japanese)
    6. Maintain natural, fluent language that reads like it was originally written in the target language
  PROMPT

  def translate_recipe(recipe, target_language)
    lang_name = LANGUAGES[target_language]
    raise ArgumentError, "Unsupported language: #{target_language}" unless lang_name

    recipe_json = build_recipe_json_for_translation(recipe)

    user_prompt = <<~PROMPT
      Translate this recipe to #{lang_name}.

      Original Recipe:
      #{recipe_json}

      Translate all text fields while keeping numeric values unchanged.
    PROMPT

    result = call_claude_structured(
      system_prompt: SYSTEM_PROMPT,
      user_prompt: user_prompt,
      tool_name: 'translate_recipe',
      tool_description: "Translate recipe content to #{lang_name}",
      json_schema: TRANSLATION_SCHEMA,
      max_tokens: 4096
    )

    result.deep_symbolize_keys
  rescue StandardError => e
    Rails.logger.error("Translation failed for #{target_language}: #{e.message}")
    raise
  end

  private

  def build_recipe_json_for_translation(recipe)
    {
      name: recipe.name,
      description: recipe.description,
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
          instruction: step.instruction_original
        }
      end,
      equipment: recipe.equipment.map(&:canonical_name)
    }.to_json
  end
end
