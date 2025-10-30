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
    parse_with_prompts('recipe_parse_text') do |user_prompt|
      user_prompt.render(text_content: text_content)
    end
  end

  # Parse a recipe from a URL
  # Uses cleaned HTML to optimize token usage before Claude parsing
  # Returns structured recipe JSON with source_url
  def parse_url(url)
    validate_url(url)

    Rails.logger.info("Attempting to parse recipe from URL: #{url}")

    raw_html = fetch_raw_html(url)
    html_content = clean_html(raw_html)

    Rails.logger.info("Cleaned HTML from #{raw_html.length} to #{html_content.length} bytes")

    result = parse_with_prompts('recipe_parse_url', enable_web_search: false) do |user_prompt|
      user_prompt.render(url: url, html_content: html_content)
    end

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

  private

  # Generic prompt-based parsing method
  # Yields user_prompt for rendering with source-specific variables
  def parse_with_prompts(prompt_base_key, **claude_options)
    system_prompt = AiPrompt.active.find_by!(prompt_key: "#{prompt_base_key}_system")
    user_prompt = AiPrompt.active.find_by!(prompt_key: "#{prompt_base_key}_user")

    rendered_user_prompt = yield(user_prompt)

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096,
      **claude_options
    )

    parse_response(response)
  end

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

  # Parse Claude's response to extract recipe JSON
  # Claude returns JSON wrapped in markdown code blocks, extract the JSON object
  def parse_response(response)
    return nil unless response.present?

    # Try to extract JSON from markdown code blocks first
    if response.include?('```json')
      json_match = response.match(/```json\s*(.*?)\s*```/m)
      if json_match
        json_str = json_match[1]
        return JSON.parse(json_str)
      end
    end

    # Try to extract JSON from plain code blocks
    if response.include?('```')
      json_match = response.match(/```\s*(.*?)\s*```/m)
      if json_match
        json_str = json_match[1]
        return JSON.parse(json_str)
      end
    end

    # Try to parse as plain JSON
    JSON.parse(response)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse Claude response as JSON: #{e.message}")
    Rails.logger.debug("Response was: #{response}")
    nil
  end
end
