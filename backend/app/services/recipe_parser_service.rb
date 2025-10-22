# Recipe Parser Service - AI-based recipe extraction from text, URL, and images
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
  # Uses web scraping (server-side fetch) since Claude cannot fetch URLs itself
  # Returns structured recipe JSON with source_url
  def parse_url(url)
    # Validate URL format
    validate_url(url)

    Rails.logger.info("Attempting to parse recipe from URL: #{url}")

    # Scrape the URL content server-side and send to Claude for parsing
    Rails.logger.info("Fetching and parsing URL content for #{url}")
    result = parse_url_with_scraping(url)

    if result
      Rails.logger.info("Successfully parsed URL using web scraping")
      result['source_url'] = url
      return result
    end

    raise "Failed to parse recipe from URL"
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

  # Try to parse URL with AI direct access (AI fetches the URL itself)
  def parse_url_direct(url)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_url_direct_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_url_direct_user')

    rendered_user_prompt = user_prompt.render(url: url)

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096
    )

    # Check if AI couldn't access the URL
    return nil if response.include?('ERROR: Cannot access URL')

    parse_response(response)
  end

  # Parse URL with web scraping fallback
  def parse_url_with_scraping(url)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_url_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_parse_url_user')

    # Scrape the URL content
    scraped_content = scrape_url(url)

    rendered_user_prompt = user_prompt.render(
      url: url,
      content: scraped_content
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096
    )

    parse_response(response)
  end

  # Parse Claude's response and extract JSON
  def parse_response(response)
    # Extract JSON from response (Claude may wrap it in markdown or text)
    json_match = response.match(/```json\s*(.*?)\s*```/m) || response.match(/\{.*\}/m)
    return nil unless json_match

    json_string = json_match[1] || json_match[0]
    recipe_data = JSON.parse(json_string)

    # Validate required fields
    validate_recipe_structure(recipe_data)

    recipe_data
  rescue JSON::ParserError => e
    Rails.logger.error("Recipe parsing failed: #{e.message}")
    nil
  end

  # Scrape content from URL
  def scrape_url(url)
    require 'net/http'
    require 'uri'

    uri = URI.parse(url)

    # Create HTTP client with SSL configuration
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    # In development, skip SSL verification (not recommended for production)
    if Rails.env.development?
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    http.read_timeout = 30
    http.open_timeout = 30

    request = Net::HTTP::Get.new(uri.request_uri)
    request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    request['Accept-Language'] = 'en-US,en;q=0.5'
    request['Accept-Encoding'] = 'gzip, deflate'
    request['Referer'] = 'https://www.allrecipes.com/'
    request['Cache-Control'] = 'no-cache'
    request['Connection'] = 'keep-alive'
    request['Upgrade-Insecure-Requests'] = '1'

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      # Strip HTML tags for simpler parsing
      strip_html(response.body)
    else
      raise "Failed to fetch URL: #{response.code} #{response.message}"
    end
  rescue StandardError => e
    Rails.logger.error("URL scraping failed for #{url}: #{e.message}")
    raise "Unable to fetch recipe from URL: #{e.message}"
  end

  # Strip HTML tags from content
  def strip_html(html)
    html.gsub(/<script.*?<\/script>/m, '')
        .gsub(/<style.*?<\/style>/m, '')
        .gsub(/<.*?>/m, ' ')
        .gsub(/\s+/, ' ')
        .strip
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
      require 'base64'
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
        model: 'claude-3-5-sonnet-20241022',
        system: system_prompt,
        messages: messages,
        max_tokens: max_tokens
      }
    )

    response['content'][0]['text']
  end

  # Validate recipe structure has required fields
  def validate_recipe_structure(recipe_data)
    required_fields = %w[name language ingredient_groups steps]

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
      unless step['id'] && step['instructions'].is_a?(Hash)
        raise "Each step must have 'id' and 'instructions' hash"
      end
    end
  end
end
