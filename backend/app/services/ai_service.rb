class AiService
  def initialize
    @client = Anthropic::Client.new(access_token: ENV['ANTHROPIC_API_KEY'])
    @last_call_time = nil
  end

  def call_claude(system_prompt:, user_prompt:, max_tokens: 2048, enable_web_search: false)
    # Rate limiting: ensure 1 second between calls
    enforce_rate_limit!

    # Retry logic with exponential backoff
    retries = 0
    max_retries = 3

    begin
      params = {
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-opus-4-5-20251101'),
        max_tokens: max_tokens,
        system: system_prompt,
        messages: [
          {
            role: 'user',
            content: user_prompt
          }
        ]
      }

      if enable_web_search
        params[:tools] = [
          {
            type: 'web_search_20250305',
            name: 'web_search',
            max_uses: 1
          }
        ]
      end

      response = @client.messages(parameters: params)

      # Log API usage for cost tracking
      log_api_usage(
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-opus-4-5-20251101'),
        input_tokens: response.dig('usage', 'input_tokens'),
        output_tokens: response.dig('usage', 'output_tokens'),
        success: true
      )

      # Extract text from response
      # With web search, Claude may use tools, so we need to find the text content
      text_content = nil
      if response.dig('content').is_a?(Array)
        response['content'].each do |item|
          if item['type'] == 'text'
            text_content = item['text']
            break
          end
        end
      else
        # Fallback for old response format
        text_content = response.dig('content', 0, 'text')
      end

      text_content

    rescue Anthropic::Error => e
      retries += 1

      # Log failed API call
      log_api_usage(
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-opus-4-5-20251101'),
        input_tokens: 0,
        output_tokens: 0,
        success: false,
        error_message: e.message
      )

      if retries <= max_retries
        wait_time = 2 ** retries # Exponential backoff: 2s, 4s, 8s
        Rails.logger.warn("Claude API Error (attempt #{retries}/#{max_retries}): #{e.message}. Retrying in #{wait_time}s...")
        sleep(wait_time)
        retry
      else
        Rails.logger.error("Claude API Error: #{e.message} - Max retries exceeded")
        raise
      end
    end
  end

  def adjust_recipe(recipe_json:, user_prompt:)
    enforce_rate_limit!

    retries = 0
    max_retries = 3

    system_prompt = <<~PROMPT
      You are a recipe adjustment assistant. Given a recipe in JSON format and a user's adjustment request, modify the recipe accordingly while maintaining the exact JSON structure.

      Rules:
      1. Keep all fields that don't need to change
      2. Adjust ingredients, steps, and descriptions as needed
      3. Update prep/cook times if the changes affect them
      4. Maintain proper measurements and cooking terminology
      5. If substituting ingredients, adjust amounts appropriately
      6. Keep the same general structure and formatting
      7. Return ONLY the modified recipe JSON - no explanations or markdown
      8. IMPORTANT: Update nutrition values when ingredients change significantly (e.g., substituting proteins, removing/adding fats, changing carb sources)

      The recipe structure must match this schema exactly:
      - title (string): Recipe title
      - description (string): Recipe description
      - ingredient_groups (array): Each with "name" (string) and "items" (array of ingredients)
        - Each item has: name (string, required), amount (string), unit (string), preparation (string), optional (boolean)
      - steps (array): Each with "instruction" (string, required), "duration_minutes" (integer)
      - servings (object): { original: integer, unit: string }
      - timing (object): { prep_minutes: integer, cook_minutes: integer, total_minutes: integer }
      - difficulty_level (string): "easy", "medium", or "hard"
      - dietary_tags (array of strings)
      - cuisines (array of strings)
      - nutrition (object): { per_serving: { calories: integer, protein_g: integer, carbs_g: integer, fat_g: integer, fiber_g: integer } }
    PROMPT

    begin
      params = {
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-opus-4-5-20251101'),
        max_tokens: 4096,
        system: system_prompt,
        messages: [
          {
            role: 'user',
            content: "Here is the recipe to adjust:\n\n#{recipe_json.to_json}\n\nUser's adjustment request: #{user_prompt}"
          }
        ]
      }

      response = @client.messages(parameters: params)

      log_api_usage(
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-opus-4-5-20251101'),
        input_tokens: response.dig('usage', 'input_tokens'),
        output_tokens: response.dig('usage', 'output_tokens'),
        success: true
      )

      text_content = extract_text_content(response)

      # Parse JSON from response - handle potential markdown code blocks
      json_text = text_content.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
      JSON.parse(json_text)

    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse AI response as JSON: #{e.message}")
      Rails.logger.error("Response text: #{text_content}")
      raise "AI returned invalid JSON format"

    rescue Anthropic::Error => e
      retries += 1

      log_api_usage(
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-opus-4-5-20251101'),
        input_tokens: 0,
        output_tokens: 0,
        success: false,
        error_message: e.message
      )

      if retries <= max_retries
        wait_time = 2 ** retries
        Rails.logger.warn("Claude API Error (attempt #{retries}/#{max_retries}): #{e.message}. Retrying in #{wait_time}s...")
        sleep(wait_time)
        retry
      else
        Rails.logger.error("Claude API Error: #{e.message} - Max retries exceeded")
        raise
      end
    end
  end

  private

  def extract_text_content(response)
    if response.dig('content').is_a?(Array)
      response['content'].each do |item|
        return item['text'] if item['type'] == 'text'
      end
    end
    response.dig('content', 0, 'text')
  end

  def enforce_rate_limit!
    return if @last_call_time.nil?

    time_since_last_call = Time.current - @last_call_time
    if time_since_last_call < 1.0
      sleep_duration = 1.0 - time_since_last_call
      Rails.logger.debug("Rate limiting: sleeping for #{sleep_duration.round(2)}s")
      sleep(sleep_duration)
    end

    @last_call_time = Time.current
  end

  def log_api_usage(model:, input_tokens:, output_tokens:, success:, error_message: nil)
    log_entry = {
      timestamp: Time.current.iso8601,
      model: model,
      input_tokens: input_tokens,
      output_tokens: output_tokens,
      success: success,
      service: self.class.name
    }
    log_entry[:error] = error_message if error_message

    Rails.logger.info("AI API Usage: #{log_entry.to_json}")
  end

  def call_claude_structured(system_prompt:, user_prompt:, tool_name:, tool_description:, json_schema:, max_tokens: 4096)
    enforce_rate_limit!

    retries = 0
    max_retries = 3

    begin
      tool = {
        name: tool_name,
        description: tool_description,
        input_schema: json_schema
      }

      params = {
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-sonnet-4-20250514'),
        max_tokens: max_tokens,
        system: system_prompt,
        tools: [tool],
        tool_choice: { type: 'tool', name: tool_name },
        messages: [
          {
            role: 'user',
            content: user_prompt
          }
        ]
      }

      response = @client.messages(parameters: params)

      log_api_usage(
        model: params[:model],
        input_tokens: response.dig('usage', 'input_tokens'),
        output_tokens: response.dig('usage', 'output_tokens'),
        success: true
      )

      tool_use_block = response['content']&.find { |block| block['type'] == 'tool_use' }

      unless tool_use_block
        Rails.logger.error("No tool_use block in response: #{response.to_json}")
        raise "Claude did not return structured output"
      end

      tool_use_block['input']

    rescue Anthropic::Error => e
      retries += 1

      log_api_usage(
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-sonnet-4-20250514'),
        input_tokens: 0,
        output_tokens: 0,
        success: false,
        error_message: e.message
      )

      if retries <= max_retries
        wait_time = 2 ** retries
        Rails.logger.warn("Claude API Error (attempt #{retries}/#{max_retries}): #{e.message}. Retrying in #{wait_time}s...")
        sleep(wait_time)
        retry
      else
        Rails.logger.error("Claude API Error: #{e.message} - Max retries exceeded")
        raise
      end
    end
  end
end
