class NutritionixClient
  API_BASE_URL = 'https://trackapi.nutritionix.com/v2'

  class Error < StandardError; end

  def initialize
    @app_id = ENV.fetch('NUTRITIONIX_APP_ID')
    @app_key = ENV.fetch('NUTRITIONIX_APP_KEY')
  end

  def natural_language_search(query)
    response = Faraday.post("#{API_BASE_URL}/natural/nutrients") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['x-app-id'] = @app_id
      req.headers['x-app-key'] = @app_key
      req.body = { query: query }.to_json
    end

    if response.success?
      JSON.parse(response.body)
    else
      raise Error, "Nutritionix API returned #{response.status}: #{response.body}"
    end
  end

  def search_item(query)
    response = Faraday.get("#{API_BASE_URL}/search/instant") do |req|
      req.headers['x-app-id'] = @app_id
      req.headers['x-app-key'] = @app_key
      req.params['query'] = query
    end

    if response.success?
      JSON.parse(response.body)
    else
      raise Error, "Nutritionix API returned #{response.status}"
    end
  end
end
