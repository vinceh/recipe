require 'rails_helper'

describe 'Api::V1::RecipesController', type: :request do
  before do
    create(:recipe, description: 'Test recipe description')
  end

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

  describe 'GET /api/v1/recipes with tags' do
    it 'includes tags in list response' do
      recipe = Recipe.first
      recipe.update!(tags: ['quick', 'easy', 'weeknight'])

      get '/api/v1/recipes'

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      recipe_item = data['recipes'].first
      expect(recipe_item).to have_key('tags')
      expect(recipe_item['tags']).to eq(['quick', 'easy', 'weeknight'])
    end

    it 'filters recipes by single tag parameter' do
      recipe = Recipe.first
      recipe.update!(tags: ['quick', 'dinner'])

      get '/api/v1/recipes', params: { tags: 'quick' }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipes'].length).to be >= 1
      data['recipes'].each do |recipe_item|
        expect(recipe_item['tags']).to include('quick')
      end
    end

    it 'filters recipes by multiple tags (AND logic)' do
      recipe = Recipe.first
      recipe.update!(tags: ['quick', 'dinner', 'healthy'])

      get '/api/v1/recipes', params: { tags: 'quick,dinner' }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      data['recipes'].each do |recipe_item|
        expect(recipe_item['tags']).to include('quick')
        expect(recipe_item['tags']).to include('dinner')
      end
    end

    it 'returns empty results when tag does not match' do
      recipe = Recipe.first
      recipe.update!(tags: ['quick'])

      get '/api/v1/recipes', params: { tags: 'nonexistent-tag' }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipes'].length).to eq(0)
    end
  end

  describe 'GET /api/v1/recipes search query (q param) includes tags' do
    it 'finds recipe by tag via search query' do
      recipe = Recipe.first
      recipe.update!(tags: ['weeknight', 'family-friendly'])
      RecipeTranslation.where(recipe_id: recipe.id).update_all(name: 'Pasta Carbonara')

      get '/api/v1/recipes', params: { q: 'weeknight' }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipes'].length).to be >= 1
      recipe_ids = data['recipes'].map { |r| r['id'] }
      expect(recipe_ids).to include(recipe.id)
    end

    it 'finds recipe by partial tag match via search query' do
      recipe = Recipe.first
      recipe.update!(tags: ['family-friendly'])
      RecipeTranslation.where(recipe_id: recipe.id).update_all(name: 'Simple Dinner')

      get '/api/v1/recipes', params: { q: 'family' }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipes'].length).to be >= 1
      recipe_ids = data['recipes'].map { |r| r['id'] }
      expect(recipe_ids).to include(recipe.id)
    end

    it 'finds recipes by name OR tag (combined results)' do
      # Create a recipe with matching name
      recipe_by_name = create(:recipe, description: 'Name match recipe')
      RecipeTranslation.find_or_create_by!(recipe_id: recipe_by_name.id, locale: 'en') do |t|
        t.name = 'Quick Chicken Dinner'
        t.description = 'A quick chicken dinner'
      end
      RecipeTranslation.where(recipe_id: recipe_by_name.id).update_all(name: 'Quick Chicken Dinner')
      recipe_by_name.update!(tags: [])

      # First recipe has matching tag but different name
      recipe_by_tag = Recipe.first
      recipe_by_tag.update!(tags: ['quick'])
      RecipeTranslation.where(recipe_id: recipe_by_tag.id).update_all(name: 'Pasta Carbonara')

      get '/api/v1/recipes', params: { q: 'quick' }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      recipe_ids = data['recipes'].map { |r| r['id'] }
      expect(recipe_ids).to include(recipe_by_name.id)
      expect(recipe_ids).to include(recipe_by_tag.id)
    end
  end

  describe 'GET /api/v1/recipes/:id with tags' do
    it 'includes tags in detail response' do
      recipe = Recipe.first
      recipe.update!(tags: ['quick', 'easy'])

      get "/api/v1/recipes/#{recipe.id}"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipe']).to have_key('tags')
      expect(data['recipe']['tags']).to eq(['quick', 'easy'])
    end

    it 'returns empty array when recipe has no tags' do
      recipe = Recipe.first
      recipe.update!(tags: [])

      get "/api/v1/recipes/#{recipe.id}"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']

      expect(data['recipe']['tags']).to eq([])
    end
  end
end
