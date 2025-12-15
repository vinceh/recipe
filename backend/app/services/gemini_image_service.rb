require 'net/http'
require 'json'
require 'base64'

class GeminiImageService
  DEFAULT_MODEL = "gemini-2.5-flash-image"
  API_BASE = "https://generativelanguage.googleapis.com/v1beta/models"

  def initialize(api_key: nil, model: nil)
    @api_key = api_key || ENV.fetch('GEMINI_API_KEY')
    @model = model || ENV.fetch('GEMINI_MODEL', DEFAULT_MODEL)
  end

  def generate_recipe_image(recipe, aspect_ratio:)
    prompt = build_prompt(recipe, aspect_ratio)
    generate_image(prompt, aspect_ratio: aspect_ratio)
  end

  def generate_step_image(recipe, step_instruction:, step_number:)
    prompt = build_step_prompt(recipe, step_instruction, step_number)
    generate_image(prompt, aspect_ratio: "16:9")
  end

  def generate_image(prompt, aspect_ratio: "1:1")
    uri = URI("#{API_BASE}/#{@model}:generateContent?key=#{@api_key}")

    request_body = {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ],
      generationConfig: {
        responseModalities: ["TEXT", "IMAGE"]
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = ENV['SSL_VERIFY_NONE'] ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
    http.read_timeout = 120

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = request_body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      error_body = JSON.parse(response.body) rescue response.body
      raise "Gemini API error (#{response.code}): #{error_body}"
    end

    result = JSON.parse(response.body)
    extract_image_from_response(result)
  end

  private

  def build_prompt(recipe, aspect_ratio)
    ingredients_list = recipe.ingredient_groups.flat_map do |group|
      group.recipe_ingredients.map do |ing|
        ing.ingredient_name
      end
    end.uniq

    cuisine = recipe.cuisines.first&.display_name || "international"

    aspect_desc = case aspect_ratio
    when "3:4" then "portrait orientation (3:4 aspect ratio, taller than wide)"
    when "1:1" then "square format (1:1 aspect ratio)"
    else aspect_ratio
    end

    <<~PROMPT
      Generate a #{aspect_desc} professional food photography image of "#{recipe.name}".

      CRITICAL FRAMING REQUIREMENT:
      - Bird's eye view (top-down shot) of a SMALL plate centered on a LARGE wooden table surface
      - The plate must occupy only 60-70% of the frame, with visible table on ALL sides
      - Show the COMPLETE plate including the ENTIRE rim - nothing cropped
      - Single serving, elegantly plated

      Ingredients visible: #{ingredients_list.join(', ')}

      Style: #{cuisine} cuisine, warm natural lighting, food magazine quality, appetizing and realistic.
    PROMPT
  end

  def build_step_prompt(recipe, step_instruction, step_number)
    cuisine = recipe.cuisines.first&.display_name || "international"

    <<~PROMPT
      Generate a 16:9 widescreen professional cooking photography image showing a specific cooking step for "#{recipe.name}".

      STEP #{step_number}: #{step_instruction}

      REQUIREMENTS:
      - Show the cooking ACTION or RESULT described in the step above
      - If the step involves a cooking technique (mixing, sautéing, kneading, etc.), show hands performing that action
      - If the step describes what something should look like, show that visual result
      - Focus on the key visual moment that would help a cook understand if they're doing it right
      - Kitchen setting with appropriate cookware visible

      Style: #{cuisine} cuisine, warm natural lighting, instructional cooking content, realistic and helpful.
      NO: text overlays, watermarks, logos, or annotations.
    PROMPT
  end

  def extract_image_from_response(result)
    candidates = result.dig('candidates') || []
    candidate = candidates.first
    return nil unless candidate

    parts = candidate.dig('content', 'parts') || []
    image_part = parts.find { |p| p['inlineData'] }
    return nil unless image_part

    inline_data = image_part['inlineData']
    {
      mime_type: inline_data['mimeType'],
      data: inline_data['data']
    }
  end
end
