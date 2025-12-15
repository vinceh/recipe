# Recipe Parser Service - AI-based recipe extraction from text, URL, and images
require 'base64'
require 'net/http'
require 'uri'
require 'openssl'
require 'nokogiri'

class RecipeParserService < AiService
  RECIPE_JSON_SCHEMA = {
    type: 'object',
    required: ['name', 'description', 'ingredient_groups', 'steps'],
    properties: {
      name: {
        type: 'string',
        description: 'Recipe title/name'
      },
      description: {
        type: 'string',
        description: 'Brief recipe description'
      },
      language: {
        type: 'string',
        description: 'Source language code (en, ja, ko, zh-tw, zh-cn, es, fr)',
        enum: ['en', 'ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr']
      },
      requires_precision: {
        type: 'boolean',
        description: 'Whether recipe requires precise measurements'
      },
      precision_reason: {
        type: 'string',
        enum: ['baking', 'confectionery', 'fermentation', 'molecular'],
        description: 'Reason for requiring precision if applicable'
      },
      difficulty_level: {
        type: 'string',
        enum: ['easy', 'medium', 'hard'],
        description: 'Recipe difficulty level'
      },
      servings: {
        type: 'object',
        properties: {
          original: { type: 'integer', description: 'Number of servings' },
          min: { type: 'integer', description: 'Minimum servings for range' },
          max: { type: 'integer', description: 'Maximum servings for range' }
        }
      },
      timing: {
        type: 'object',
        properties: {
          prep_minutes: { type: 'integer', description: 'Preparation time in minutes' },
          cook_minutes: { type: 'integer', description: 'Cooking time in minutes' },
          total_minutes: { type: 'integer', description: 'Total time in minutes' }
        }
      },
      nutrition: {
        type: 'object',
        properties: {
          per_serving: {
            type: 'object',
            properties: {
              calories: { type: 'integer' },
              protein_g: { type: 'integer' },
              carbs_g: { type: 'integer' },
              fat_g: { type: 'integer' },
              fiber_g: { type: 'integer' }
            }
          }
        }
      },
      aliases: {
        type: 'array',
        items: { type: 'string' },
        description: 'Alternative names for the recipe'
      },
      dietary_tags: {
        type: 'array',
        items: { type: 'string' },
        description: 'Dietary tags as lowercase hyphenated keys: vegetarian, vegan, gluten-free, dairy-free, pork-free, halal, kosher, keto-friendly, paleo, low-carb, low-sodium, egg-free, soy-free, tree-nut-free, peanut-free, pescatarian, red-meat-free, wheat-free'
      },
      cuisines: {
        type: 'array',
        items: { type: 'string' },
        description: 'Cuisine types as lowercase hyphenated keys: japanese, korean, chinese, cantonese, sichuan, taiwanese, thai, vietnamese, filipino, indonesian, malaysian, singaporean, indian, north-indian, south-indian, italian, french, spanish, greek, mexican, american, southern, cajun, british, german, mediterranean, middle-eastern, turkish, lebanese, moroccan, ethiopian, brazilian, peruvian, caribbean, fusion, asian-fusion'
      },
      tags: {
        type: 'array',
        items: { type: 'string' },
        description: 'Recipe categorization tags (3-6 tags): cooking-method (braised, stir-fried, grilled, baked, steamed, deep-fried, slow-cooked, roasted), meal-type (breakfast, lunch, dinner, snack, appetizer, dessert, side-dish), occasion (weeknight, holiday, party, meal-prep, date-night), season (summer, winter, spring, fall), texture/taste (spicy, savory, sweet, crispy, creamy, hearty, light, refreshing), main-ingredient (chicken, beef, pork, seafood, tofu, vegetables, pasta, rice, noodles)'
      },
      equipment: {
        type: 'array',
        items: { type: 'string' },
        description: 'Required cooking equipment'
      },
      ingredient_groups: {
        type: 'array',
        items: {
          type: 'object',
          required: ['name', 'items'],
          properties: {
            name: { type: 'string', description: 'Group name (e.g., "For the sauce", "Main ingredients")' },
            items: {
              type: 'array',
              items: {
                type: 'object',
                required: ['name'],
                properties: {
                  name: { type: 'string', description: 'Ingredient name' },
                  amount: { type: 'string', description: 'Quantity as string (e.g., "2", "1/2")' },
                  unit: { type: 'string', description: 'Measurement unit (e.g., "cups", "tbsp")' },
                  preparation: { type: 'string', description: 'Preparation notes (e.g., "diced", "minced")' },
                  optional: { type: 'boolean', description: 'Whether ingredient is optional' }
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
          required: ['instruction'],
          properties: {
            instruction: { type: 'string', description: 'Step instruction text' },
            section_heading: { type: 'string', description: 'Optional section heading before this step' },
            duration_minutes: { type: 'integer', description: 'Estimated time for this step' }
          }
        }
      }
    }
  }.freeze

  SYSTEM_PROMPT = <<~PROMPT
    You are a recipe parsing expert. Extract recipe information from the provided content and structure it according to the schema.

    Guidelines:
    - Extract all ingredients with proper amounts, units, and preparation notes
    - Group ingredients logically (e.g., "For the sauce", "For the dough") - use "Main Ingredients" if no grouping exists
    - Extract step-by-step instructions clearly, preserving any section headings
    - If instructions have section headers (like "Prepare the beef:" or "For the sauce:"), set them as section_heading on the first step of that section
    - Infer timing, difficulty, and dietary information when possible
    - IMPORTANT: For dietary_tags, use ONLY lowercase hyphenated keys from the allowed list (e.g., dairy-free, gluten-free, pork-free)
    - IMPORTANT: For cuisines, use ONLY lowercase hyphenated keys from the allowed list (e.g., taiwanese, chinese, japanese)
    - For tags, use descriptive categorization tags that help with recipe discovery (cooking method, meal type, main ingredient, occasion)
    - For units, use abbreviated forms: tbsp, tsp, cup, oz, lb, g, ml, L (not "tablespoons" or "teaspoons")
    - Detect the source language of the recipe and set the language field accordingly
    - Be thorough but don't hallucinate information that isn't present
  PROMPT

  def parse_text_block(text_content)
    Rails.logger.info("Parsing recipe from text block (#{text_content.length} chars)")

    result = call_claude_structured(
      system_prompt: SYSTEM_PROMPT,
      user_prompt: "Parse this recipe:\n\n#{text_content}",
      tool_name: 'parse_recipe',
      tool_description: 'Parse and structure recipe information',
      json_schema: RECIPE_JSON_SCHEMA,
      max_tokens: 4096
    )

    result.deep_symbolize_keys
  rescue StandardError => e
    Rails.logger.error("Text parse failed: #{e.message}")
    raise
  end

  def parse_url(url)
    validate_url(url)

    Rails.logger.info("Attempting to parse recipe from URL: #{url}")

    raw_html = fetch_raw_html(url)
    html_content = clean_html(raw_html)

    Rails.logger.info("Cleaned HTML from #{raw_html.length} to #{html_content.length} bytes")

    result = call_claude_structured(
      system_prompt: SYSTEM_PROMPT,
      user_prompt: "Parse this recipe from #{url}:\n\n#{html_content}",
      tool_name: 'parse_recipe',
      tool_description: 'Parse and structure recipe information',
      json_schema: RECIPE_JSON_SCHEMA,
      max_tokens: 4096
    )

    parsed = result.deep_symbolize_keys
    parsed[:source_url] = url

    Rails.logger.info("Successfully parsed URL content with structured output")
    parsed
  rescue StandardError => e
    Rails.logger.error("URL parse failed: #{e.message}")
    raise
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

  # Extract pure text from HTML, removing all markup and noise
  # Removes ~97% of tokens compared to raw HTML while preserving recipe content
  def clean_html(raw_html)
    HtmlToTextConverter.new(raw_html).convert
  rescue => e
    Rails.logger.error("Failed to clean HTML: #{e.message}")
    raise "Could not clean HTML: #{e.message}"
  end
end
