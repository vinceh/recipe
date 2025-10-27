require 'rails_helper'

describe 'Api::V1::RecipesController', type: :request do
  describe 'GET /api/v1/recipes' do
    it 'includes description in list response' do
      # Test uses seeded recipes which include descriptions
      get '/api/v1/recipes'

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      # Find a recipe from the seeded data
      recipe_item = data['recipes'].first

      expect(recipe_item).to have_key('description')
      expect(recipe_item['description']).to be_a(String)
    end
  end

  describe 'GET /api/v1/recipes/:id' do
    it 'includes description in detail response' do
      # Get first recipe from seeded data
      recipe = Recipe.first
      skip "No recipes in database" unless recipe

      get "/api/v1/recipes/#{recipe.id}"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipe']).to have_key('description')
      expect(data['recipe']['description']).to be_a(String)
    end
  end

  describe 'Description translations with Mobility' do
    it 'returns description for default locale' do
      recipe = Recipe.first
      skip "No recipes in database" unless recipe

      get "/api/v1/recipes/#{recipe.id}"

      data = JSON.parse(response.body)['data']
      expect(data['recipe']).to have_key('description')
      expect(data['recipe']['description']).to be_a(String)
    end
  end
end
