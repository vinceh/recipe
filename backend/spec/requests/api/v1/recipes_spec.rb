require 'rails_helper'

describe 'Api::V1::RecipesController', type: :request do
  describe 'GET /api/v1/recipes' do
    it 'includes description in list response' do
      get '/api/v1/recipes'

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      recipe_item = data['recipes'].first

      expect(recipe_item).to have_key('description')
      expect(recipe_item['description']).to be_a(String)
    end
  end

  describe 'GET /api/v1/recipes/:id' do
    it 'includes description in detail response' do
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

  describe 'GET /api/v1/recipes with difficulty_level' do
    it 'includes difficulty_level in list response' do
      get '/api/v1/recipes'

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      recipe_item = data['recipes'].first

      expect(recipe_item).to have_key('difficulty_level')
      expect(recipe_item['difficulty_level']).to be_in(['easy', 'medium', 'hard'])
    end

    it 'filters recipes by difficulty_level parameter' do
      hard_recipe = Recipe.find_by(difficulty_level: :hard) || Recipe.first
      if hard_recipe
        hard_recipe.update!(difficulty_level: :hard)
      else
        skip "No recipes in database"
      end

      get '/api/v1/recipes', params: { difficulty_level: 'hard' }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      data['recipes'].each do |recipe_item|
        expect(recipe_item['difficulty_level']).to eq('hard')
      end
    end
  end

  describe 'GET /api/v1/recipes/:id with difficulty_level' do
    it 'includes difficulty_level in detail response' do
      recipe = Recipe.first
      skip "No recipes in database" unless recipe

      get "/api/v1/recipes/#{recipe.id}"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipe']).to have_key('difficulty_level')
      expect(data['recipe']['difficulty_level']).to be_in(['easy', 'medium', 'hard'])
    end
  end

  describe 'GET /api/v1/recipes with image_url' do
    it 'includes image_url in list response' do
      get '/api/v1/recipes'

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      recipe_item = data['recipes'].first
      expect(recipe_item).to have_key('image_url')
    end

    it 'image_url contains a valid URL' do
      get '/api/v1/recipes'

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      recipe_item = data['recipes'].first
      expect(recipe_item['image_url']).to match(%r{^https?://})
    end
  end

  describe 'GET /api/v1/recipes/:id with image_url' do
    it 'includes image_url in detail response' do
      recipe = Recipe.first
      skip "No recipes in database" unless recipe

      get "/api/v1/recipes/#{recipe.id}"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipe']).to have_key('image_url')
    end

    it 'image_url contains a valid URL in detail response' do
      recipe = Recipe.first
      skip "No recipes in database" unless recipe

      get "/api/v1/recipes/#{recipe.id}"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipe']['image_url']).to match(%r{^https?://})
    end
  end
end
