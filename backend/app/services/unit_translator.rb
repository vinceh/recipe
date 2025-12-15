class UnitTranslator < AiService
  LANGUAGES = {
    'ja' => 'Japanese',
    'ko' => 'Korean',
    'zh-tw' => 'Traditional Chinese (Taiwan)',
    'zh-cn' => 'Simplified Chinese (China)',
    'es' => 'Spanish',
    'fr' => 'French'
  }.freeze

  def translate_unit(unit_name, category: nil)
    system_prompt = <<~PROMPT
      You are a professional translator specializing in culinary terminology.
      Translate cooking measurement units accurately for international recipes.

      Rules:
      1. For metric units (g, kg, ml, L, cm), keep them as-is in most languages
      2. For volume measurements (tbsp, tsp, cup), use the standard cooking abbreviations
      3. For count units (piece, slice, clove), use the appropriate counter word
      4. Maintain culinary context and cultural appropriateness
      5. Return ONLY a valid JSON object with language codes as keys
    PROMPT

    user_prompt = <<~PROMPT
      Translate this cooking unit to all languages: "#{unit_name}"
      #{category ? "Category: #{category}" : ""}

      Return JSON in this exact format:
      {
        "en": "#{unit_name}",
        "ja": "Japanese translation",
        "ko": "Korean translation",
        "zh-tw": "Traditional Chinese translation",
        "zh-cn": "Simplified Chinese translation",
        "es": "Spanish translation",
        "fr": "French translation"
      }
    PROMPT

    response = call_claude(
      system_prompt: system_prompt,
      user_prompt: user_prompt,
      max_tokens: 512
    )

    parse_translation_response(response)
  end

  def translate_and_save(unit)
    translations = translate_unit(unit.canonical_name, category: unit.category)
    return false unless translations

    LANGUAGES.keys.each do |locale|
      i18n_locale = locale.to_sym
      translated_name = translations[locale]
      next unless translated_name.present?

      I18n.with_locale(i18n_locale) do
        unit.name = translated_name
        unit.save!
      end
    end

    true
  rescue StandardError => e
    Rails.logger.error("Unit translation failed for #{unit.canonical_name}: #{e.message}")
    false
  end

  private

  def parse_translation_response(response)
    json_match = response.match(/```json\s*(\{.*?\})\s*```/m) || response.match(/(\{.*\})/m)
    return nil unless json_match

    JSON.parse(json_match[1])
  rescue JSON::ParserError => e
    Rails.logger.error("Unit translation parsing failed: #{e.message}")
    nil
  end
end
