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

    rendered_user_prompt = user_prompt.render(
      target_language: lang_name,
      recipe_json: recipe.to_json
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096
    )

    parse_translation_response(response, target_language)
  end

  private

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
