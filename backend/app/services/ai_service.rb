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
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-haiku-4-5-20251001'),
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
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-haiku-4-5-20251001'),
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
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-haiku-4-5-20251001'),
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

  private

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
end
