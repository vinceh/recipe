# Recipe Parser Service - AI-based recipe extraction from text, URL, and images
require 'base64'
require 'net/http'
require 'uri'
require 'openssl'
require 'nokogiri'

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
  # Uses tiered approach: JSON-LD extraction > Claude parsing
  # Returns structured recipe JSON with source_url
  def parse_url(url)
    validate_url(url)

    Rails.logger.info("Attempting to parse recipe from URL: #{url}")

    # Fetch raw HTML
    raw_html = fetch_raw_html(url)

    # Tier 1: Try JSON-LD structured data extraction (0 API cost, instant)
    if structured_recipe = extract_json_ld_recipe(raw_html)
      # Validate that JSON-LD extraction gave us sufficient detail
      if looks_complete?(structured_recipe)
        Rails.logger.info("Successfully extracted complete recipe from JSON-LD (Tier 1)")
        structured_recipe['source_url'] = url
        return transform_for_frontend(structured_recipe)
      else
        Rails.logger.info("JSON-LD extraction incomplete (#{structured_recipe['steps']&.length || 0} steps), falling back to Claude (Tier 2)")
      end
    else
      Rails.logger.info("No JSON-LD found, falling back to Claude parsing (Tier 2)")
    end

    # Tier 2: Fall back to Claude parsing with cleaned HTML
    html_content = clean_html(raw_html)

    # Get prompts from database
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_url_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_url_user')

    # Send cleaned HTML content to Claude for parsing
    rendered_user_prompt = user_prompt.render(url: url, html_content: html_content)

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096,
      enable_web_search: false
    )

    result = parse_response(response)
    if result.is_a?(Hash)
      Rails.logger.info("Successfully parsed URL content with Claude")
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

  # Fetch raw HTML from URL (no cleaning)
  def fetch_raw_html(url)
    uri = URI.parse(url)

    Net::HTTP.start(
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
  rescue => e
    Rails.logger.error("Failed to fetch URL: #{e.message}")
    raise "Could not fetch content from URL: #{e.message}"
  end

  # Clean HTML by removing noise elements and unnecessary attributes
  def clean_html(raw_html)
    # Parse HTML with configuration to handle encoding better
    doc = Nokogiri::HTML(raw_html) do |config|
      config.noblanks
    end

    # Remove script, style, and other unwanted elements
    doc.css('script, style, iframe, noscript, meta, link[rel="stylesheet"], svg').remove

    # Remove unwanted attributes that add noise
    doc.xpath('//@style | //@class | //@id | //@onclick | //@onload').remove

    # Get cleaned HTML
    html = doc.to_html

    # Limit to first 100KB to avoid API request size limits
    html = html[0...(100 * 1024)] if html.length > 100_000

    html
  rescue => e
    Rails.logger.error("Failed to clean HTML: #{e.message}")
    raise "Could not clean HTML: #{e.message}"
  end

  # Extract Recipe structured data from JSON-LD script tags (Tier 1: 0 API cost)
  def extract_json_ld_recipe(raw_html)
    doc = Nokogiri::HTML(raw_html)

    # Find all JSON-LD script tags
    json_ld_scripts = doc.css('script[type="application/ld+json"]')

    json_ld_scripts.each do |script|
      begin
        data = JSON.parse(script.content)

        # Extract items to search based on structure
        items_to_search = []

        if data.is_a?(Hash)
          if data['@graph'].is_a?(Array)
            # Handle @graph structure (common in WordPress schema)
            items_to_search = data['@graph']
          else
            # Single object
            items_to_search = [data]
          end
        elsif data.is_a?(Array)
          # Array of objects
          items_to_search = data
        end

        # Find Recipe type in the JSON-LD data
        recipe = items_to_search.find { |item| item.is_a?(Hash) && item['@type'] == 'Recipe' }

        if recipe
          Rails.logger.info("Found JSON-LD Recipe: #{recipe['name']}")
          return normalize_json_ld_recipe(recipe)
        end
      rescue JSON::ParserError => e
        Rails.logger.debug("Failed to parse JSON-LD: #{e.message}")
        next
      end
    end

    nil
  rescue => e
    Rails.logger.debug("Error extracting JSON-LD: #{e.message}")
    nil
  end

  # Normalize JSON-LD Recipe data to match our internal format
  def normalize_json_ld_recipe(json_ld_recipe)
    {
      'name' => json_ld_recipe['name'],
      'language' => 'en',
      'servings_original' => extract_servings(json_ld_recipe['recipeYield']),
      'prep_minutes' => duration_to_minutes(json_ld_recipe['prepTime']),
      'cook_minutes' => duration_to_minutes(json_ld_recipe['cookTime']),
      'total_minutes' => duration_to_minutes(json_ld_recipe['totalTime']),
      'ingredient_groups' => normalize_ingredients(json_ld_recipe['recipeIngredient']),
      'steps' => normalize_steps(json_ld_recipe['recipeInstructions']),
      'equipment' => json_ld_recipe['tool'] || [],
      'admin_notes' => "Extracted from JSON-LD structured data on #{Time.current.strftime('%B %d, %Y')}. Source: #{json_ld_recipe['url'] || 'Unknown'}"
    }
  end

  # Extract servings count from recipeYield (can be string or number)
  def extract_servings(recipe_yield)
    return nil unless recipe_yield

    if recipe_yield.is_a?(Array)
      recipe_yield = recipe_yield.first
    end

    if recipe_yield.is_a?(String)
      # Try to extract number from strings like "4 servings" or "Serves 4"
      recipe_yield.match(/\d+/)&.[](0)&.to_i
    else
      recipe_yield.to_i
    end
  end

  # Convert ISO 8601 duration to minutes (e.g., PT30M = 30 minutes)
  def duration_to_minutes(duration)
    return nil unless duration

    # Parse ISO 8601 format: PT[n]H[n]M[n]S
    if duration.match?(/^PT/)
      hours = duration.match(/(\d+)H/)&.[](1)&.to_i || 0
      minutes = duration.match(/(\d+)M/)&.[](1)&.to_i || 0
      (hours * 60) + minutes
    else
      nil
    end
  end

  # Normalize ingredients from JSON-LD format to internal format
  def normalize_ingredients(recipe_ingredients)
    return [] unless recipe_ingredients

    # Group ingredients into a single group since JSON-LD doesn't have grouping
    items = recipe_ingredients.map do |ingredient|
      {
        'name' => ingredient,
        'amount' => nil,
        'unit' => nil,
        'preparation' => nil,
        'optional' => false
      }
    end

    [{ 'name' => 'Ingredients', 'items' => items }]
  end

  # Normalize recipe steps from JSON-LD format to internal format
  def normalize_steps(recipe_instructions)
    return [] unless recipe_instructions

    case recipe_instructions
    when Array
      # Array of strings or objects
      recipe_instructions.each_with_index.map do |instruction, idx|
        {
          'instructions' => instruction.is_a?(String) ? instruction : instruction['text'],
          'order' => idx + 1
        }
      end
    when String
      # Single string
      [{ 'instructions' => recipe_instructions, 'order' => 1 }]
    else
      # Fallback
      []
    end
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

  # Check if extracted recipe looks complete (not a summary)
  # JSON-LD often contains simplified versions of recipes with only 5-10 steps
  # This detects incomplete extractions and triggers fallback to Claude
  def looks_complete?(recipe_data)
    steps = recipe_data['steps'] || []
    ingredients = recipe_data['ingredient_groups']&.sum { |g| g['items']&.length || 0 } || 0

    # Consider complete if:
    # - Has at least 5 steps (summaries usually have 3-5)
    # - Has at least 3 ingredients
    # - Has reasonable timing info
    steps.length >= 5 && ingredients >= 3
  end
end
