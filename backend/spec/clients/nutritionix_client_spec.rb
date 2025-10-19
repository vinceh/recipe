require 'rails_helper'

RSpec.describe NutritionixClient, type: :client do
  let(:client) { described_class.new }
  let(:app_id) { 'test_app_id' }
  let(:app_key) { 'test_app_key' }

  before do
    allow(ENV).to receive(:fetch).with('NUTRITIONIX_APP_ID').and_return(app_id)
    allow(ENV).to receive(:fetch).with('NUTRITIONIX_APP_KEY').and_return(app_key)
  end

  describe '#natural_language_search' do
    let(:query) { '100g chicken breast' }
    let(:success_response) do
      {
        'foods' => [
          {
            'food_name' => 'chicken breast',
            'serving_weight_grams' => 100,
            'nf_calories' => 165,
            'nf_protein' => 31,
            'nf_total_carbohydrate' => 0,
            'nf_total_fat' => 3.6,
            'nf_dietary_fiber' => 0
          }
        ]
      }
    end

    it 'makes a POST request to natural/nutrients endpoint' do
      stub_request(:post, "#{NutritionixClient::API_BASE_URL}/natural/nutrients")
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'x-app-id' => app_id,
            'x-app-key' => app_key
          },
          body: { query: query }.to_json
        )
        .to_return(status: 200, body: success_response.to_json)

      result = client.natural_language_search(query)

      expect(result).to eq(success_response)
    end

    it 'returns parsed JSON on success' do
      stub_request(:post, "#{NutritionixClient::API_BASE_URL}/natural/nutrients")
        .to_return(status: 200, body: success_response.to_json)

      result = client.natural_language_search(query)

      expect(result['foods']).to be_an(Array)
      expect(result['foods'].first['nf_calories']).to eq(165)
    end

    it 'raises error on API failure' do
      stub_request(:post, "#{NutritionixClient::API_BASE_URL}/natural/nutrients")
        .to_return(status: 401, body: 'Unauthorized')

      expect {
        client.natural_language_search(query)
      }.to raise_error(NutritionixClient::Error, /401/)
    end
  end

  describe '#search_item' do
    let(:query) { 'chicken' }
    let(:success_response) do
      {
        'common' => [
          { 'food_name' => 'chicken breast' },
          { 'food_name' => 'chicken thigh' }
        ]
      }
    end

    it 'makes a GET request to search/instant endpoint' do
      stub_request(:get, "#{NutritionixClient::API_BASE_URL}/search/instant")
        .with(
          query: { 'query' => query },
          headers: {
            'x-app-id' => app_id,
            'x-app-key' => app_key
          }
        )
        .to_return(status: 200, body: success_response.to_json)

      result = client.search_item(query)

      expect(result).to eq(success_response)
    end

    it 'raises error on API failure' do
      stub_request(:get, "#{NutritionixClient::API_BASE_URL}/search/instant")
        .to_return(status: 500)

      expect {
        client.search_item(query)
      }.to raise_error(NutritionixClient::Error, /500/)
    end
  end
end
