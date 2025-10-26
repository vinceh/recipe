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
  # Uses cleaned HTML to optimize token usage before Claude parsing
  # Returns structured recipe JSON with source_url
  def parse_url(url)
    validate_url(url)

    Rails.logger.info("Attempting to parse recipe from URL: #{url}")

    # Fetch raw HTML
    raw_html = fetch_raw_html(url)

    # Clean HTML to reduce token usage (removes 60-80% of tokens)
    html_content = clean_html(raw_html)

    Rails.logger.info("Cleaned HTML from #{raw_html.length} to #{html_content.length} bytes")

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
end
