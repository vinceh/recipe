# Recipe Parser Service - AI-based recipe extraction from text, URL, and images
require 'base64'
require 'net/http'
require 'uri'
require 'openssl'

class RecipeParserService < AiService
  # Parse a large text block containing a recipe
  # Returns structured recipe JSON
  def parse_text_block(text_content)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_text_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_text_user')

    rendered_user_prompt = user_prompt.render(text_content: text_content)

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096
    )

    parse_response(response)
  end

  # Parse a recipe from a URL
  # Fetches HTML content and sends to Claude for parsing
  # Returns structured recipe JSON with source_url
  def parse_url(url)
    validate_url(url)

    Rails.logger.info("Attempting to parse recipe from URL: #{url}")

    # Fetch HTML content from the URL
    html_content = fetch_url_content(url)

    # Get prompts from database
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_url_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_url_user')

    # Send HTML content to Claude for parsing
    rendered_user_prompt = user_prompt.render(url: url, html_content: html_content)

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096,
      enable_web_search: false
    )

    result = parse_response(response)
    if result.is_a?(Hash)
      Rails.logger.info("Successfully parsed URL content")
      result['source_url'] = url
      return result
    end

    raise "Failed to parse recipe from URL"
  rescue StandardError => e
    Rails.logger.error("URL parse failed: #{e.message}")
    raise
  end

  # Parse a recipe from an image using Claude Vision API
  # Returns structured recipe JSON
  def parse_image(image_path_or_url)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_image_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_image_user')

    # Prepare image for Claude Vision API
    image_content = prepare_image(image_path_or_url)

    response = call_claude_vision(
      system_prompt: system_prompt.prompt_text,
      user_prompt: user_prompt.prompt_text,
      image_content: image_content,
      max_tokens: 4096
    )

    parse_response(response)
  end

  private

  # Validate URL format
  def validate_url(url)
    raise "URL is required" if url.blank?

    begin
      uri = URI.parse(url)
      raise "Invalid URL format" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      raise "Invalid URL format"
    end
  end

  # Fetch HTML content from a URL
  def fetch_url_content(url)
    uri = URI.parse(url)

    html = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https',
      verify_mode: OpenSSL::SSL::VERIFY_NONE,
      read_timeout: 10
    ) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      request['User-Agent'] = 'Mozilla/5.0 (compatible; RecipeParser/1.0)'

      response = http.request(request)
      raise "Failed to fetch URL: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    # Remove script and style tags to reduce size
    html = html.gsub(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/im, '')
    html = html.gsub(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/im, '')

    # Limit to first 100KB to avoid API request size limits
    html = html[0...(100 * 1024)] if html.length > 100_000

    html
  rescue => e
    Rails.logger.error("Failed to fetch URL content: #{e.message}")
    raise "Could not fetch content from URL: #{e.message}"
  end


  # Parse Claude's response and extract JSON
  def parse_response(response)
    # Extract JSON from response (Claude may wrap it in markdown or text)
    json_match = response.match(/```json\s*(.*?)\s*```/m) || response.match(/\{.*\}/m)
    unless json_match
      Rails.logger.error("Could not extract JSON from response: #{response[0..500]}")
      return nil
    end

    json_string = json_match[1] || json_match[0]
    recipe_data = JSON.parse(json_string)

    # Validate required fields
    validate_recipe_structure(recipe_data)

    # Transform to frontend format for use in form
    transform_for_frontend(recipe_data)
  rescue JSON::ParserError => e
    Rails.logger.error("Recipe parsing failed: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("Recipe processing failed: #{e.class} - #{e.message}")
    nil
  end

  # Prepare image for Claude Vision API
  def prepare_image(image_path_or_url)
    if image_path_or_url.start_with?('http')
      # URL - Claude can handle directly
      {
        type: 'url',
        url: image_path_or_url
      }
    else
      # Local file path - need to base64 encode
      image_data = File.read(image_path_or_url)
      encoded_image = Base64.strict_encode64(image_data)

      # Detect media type
      media_type = case File.extname(image_path_or_url).downcase
                   when '.jpg', '.jpeg' then 'image/jpeg'
                   when '.png' then 'image/png'
                   when '.webp' then 'image/webp'
                   when '.gif' then 'image/gif'
                   else 'image/jpeg'
                   end

      {
        type: 'base64',
        media_type: media_type,
        data: encoded_image
      }
    end
  end

  # Call Claude Vision API with image
  def call_claude_vision(system_prompt:, user_prompt:, image_content:, max_tokens: 4096)
    # Build vision API request
    messages = [
      {
        role: 'user',
        content: [
          {
            type: 'image',
            source: if image_content[:type] == 'url'
                      {
                        type: 'url',
                        url: image_content[:url]
                      }
                    else
                      {
                        type: 'base64',
                        media_type: image_content[:media_type],
                        data: image_content[:data]
                      }
                    end
          },
          {
            type: 'text',
            text: user_prompt
          }
        ]
      }
    ]

    client = Anthropic::Client.new(access_token: ENV['ANTHROPIC_API_KEY'])

    response = client.messages(
      parameters: {
        model: ENV['ANTHROPIC_MODEL'] || 'claude-haiku-4-5-20251001',
        system: system_prompt,
        messages: messages,
        max_tokens: max_tokens
      }
    )

    response['content'][0]['text']
  end

  # Validate recipe structure has required fields
  def validate_recipe_structure(recipe_data)
    required_fields = %w[name ingredient_groups steps]

    missing_fields = required_fields - recipe_data.keys
    if missing_fields.any?
      raise "Invalid recipe structure. Missing fields: #{missing_fields.join(', ')}"
    end

    # Validate ingredient_groups structure
    unless recipe_data['ingredient_groups'].is_a?(Array)
      raise "ingredient_groups must be an array"
    end

    recipe_data['ingredient_groups'].each do |group|
      unless group['name'] && group['items'].is_a?(Array)
        raise "Each ingredient group must have 'name' and 'items' array"
      end
    end

    # Validate steps structure
    unless recipe_data['steps'].is_a?(Array)
      raise "steps must be an array"
    end

    recipe_data['steps'].each do |step|
      unless step['instructions'].present?
        raise "Each step must have 'instructions'"
      end
    end
  end

  # Transform parsed recipe data to frontend format for form display
  def transform_for_frontend(recipe_data)
    valid_dietary_tags = DataReference.where(reference_type: 'dietary_tag').pluck(:key).to_set
    valid_cuisines = DataReference.where(reference_type: 'cuisine').pluck(:key).to_set
    valid_dish_types = DataReference.where(reference_type: 'dish_type').pluck(:key).to_set
    valid_recipe_types = DataReference.where(reference_type: 'recipe_type').pluck(:key).to_set

    {
      name: recipe_data['name'],
      language: recipe_data['language'] || 'en',
      source_url: recipe_data['source_url'],
      requires_precision: recipe_data['requires_precision'] || false,
      precision_reason: recipe_data['precision_reason'],
      servings: {
        original: recipe_data['servings_original'],
        min: recipe_data['servings_min'],
        max: recipe_data['servings_max']
      },
      timing: {
        prep_minutes: recipe_data['prep_minutes'],
        cook_minutes: recipe_data['cook_minutes'],
        total_minutes: recipe_data['total_minutes']
      },
      aliases: recipe_data['aliases'] || [],
      dietary_tags: (recipe_data['dietary_tags'] || []).select { |tag| valid_dietary_tags.include?(tag) },
      cuisines: (recipe_data['cuisines'] || []).select { |tag| valid_cuisines.include?(tag) },
      dish_types: (recipe_data['dish_types'] || []).select { |tag| valid_dish_types.include?(tag) },
      recipe_types: (recipe_data['recipe_types'] || []).select { |tag| valid_recipe_types.include?(tag) },
      ingredient_groups: recipe_data['ingredient_groups'] || [],
      steps: (recipe_data['steps'] || []).each_with_index.map do |step, idx|
        {
          order: idx + 1,
          instruction: step['instructions'].is_a?(String) ? step['instructions'] :
                       step['instructions'].is_a?(Hash) ? (step.dig('instructions', 'original') || step.dig('instructions', 'en') || step['instructions'].values.first) :
                       step['instruction']
        }
      end,
      equipment: recipe_data['equipment'] || [],
      admin_notes: recipe_data['admin_notes']
    }
  end

  # Transform parsed JSONB-like structure to normalized attributes format
  def transform_to_normalized_attributes(recipe_data)
    {
      name: recipe_data['name'],
      source_language: recipe_data['language'] || 'en',
      source_url: recipe_data['source_url'],
      servings_original: recipe_data.dig('servings', 'original') || recipe_data['servings_original'],
      servings_min: recipe_data.dig('servings', 'min') || recipe_data['servings_min'],
      servings_max: recipe_data.dig('servings', 'max') || recipe_data['servings_max'],
      prep_minutes: recipe_data.dig('timing', 'prep_minutes') || recipe_data['prep_minutes'],
      cook_minutes: recipe_data.dig('timing', 'cook_minutes') || recipe_data['cook_minutes'],
      total_minutes: recipe_data.dig('timing', 'total_minutes') || recipe_data['total_minutes'],
      requires_precision: recipe_data['requires_precision'] || false,
      admin_notes: recipe_data['admin_notes'],
      ingredient_groups_attributes: recipe_data['ingredient_groups'].each_with_index.map do |group, idx|
        {
          name: group['name'],
          position: idx + 1,
          recipe_ingredients_attributes: group['items'].each_with_index.map do |item, item_idx|
            {
              ingredient_name: item['name'],
              amount: item['amount'],
              unit: item['unit'],
              preparation_notes: item['preparation'] || item['notes'],
              optional: item['optional'] || false,
              position: item_idx + 1
            }
          end
        }
      end,
      recipe_steps_attributes: recipe_data['steps'].each_with_index.map do |step, idx|
        # Handle different instruction formats from Claude
        instruction = if step['instructions'].is_a?(String)
                        step['instructions']
                      elsif step['instructions'].is_a?(Hash)
                        step.dig('instructions', 'original') || step.dig('instructions', 'en') || step['instructions'].values.first
                      else
                        step['instruction'] # fallback to singular
                      end

        {
          step_number: idx + 1,
          instruction_original: instruction
        }
      end
    }
  end
end
