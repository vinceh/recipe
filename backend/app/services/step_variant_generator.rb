class StepVariantGenerator < AiService
  def generate_easier_variant(recipe, step)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_easier_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_easier_user')

    rendered_user_prompt = user_prompt.render(
      recipe_name: recipe.name,
      cuisines: recipe.cuisines.join(', '),
      recipe_types: recipe.recipe_types.join(', '),
      step_order: step['order'],
      step_title: step['title'] || "Step #{step['order']}",
      original_instruction: step.dig('instructions', 'original'),
      equipment: step['equipment']&.join(', ') || 'None specified',
      ingredients: extract_step_ingredients(recipe, step).join(', ')
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 1024
    )

    parse_variant_response(response)
  end

  def generate_no_equipment_variant(recipe, step)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_no_equipment_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_no_equipment_user')

    rendered_user_prompt = user_prompt.render(
      recipe_name: recipe.name,
      step_order: step['order'],
      step_title: step['title'] || "Step #{step['order']}",
      original_instruction: step.dig('instructions', 'original'),
      equipment: step['equipment']&.join(', ') || 'None'
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 1024
    )

    parse_variant_response(response)
  end

  private

  def extract_step_ingredients(recipe, step)
    # Extract ingredient names mentioned in this step
    step_text = step.dig('instructions', 'original')
    return [] unless step_text

    recipe.ingredient_groups.flat_map do |group|
      group['items'].select do |ing|
        step_text.downcase.include?(ing['name'].downcase)
      end.map { |ing| "#{ing['amount']} #{ing['unit']} #{ing['name']}" }
    end
  end

  def parse_variant_response(response)
    # Try to extract JSON from response
    json_match = response.match(/\{[^}]+\}/)
    return response unless json_match

    parsed = JSON.parse(json_match[0])
    parsed['text']
  rescue JSON::ParserError
    response # Return raw text if JSON parsing fails
  end
end
