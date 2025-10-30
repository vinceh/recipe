require 'rails_helper'

describe 'Admin::RecipesController', type: :request do
  describe 'POST /admin/recipes with image' do
    it 'creates a recipe with an image' do
      image_file = fixture_file_upload('test_image.png', 'image/png')

      post '/admin/recipes', params: {
        recipe: {
          name: 'Test Recipe',
          description: 'A test recipe',
          source_language: 'en',
          servings_original: 2,
          prep_minutes: 10,
          cook_minutes: 20,
          total_minutes: 30,
          difficulty_level: 'medium',
          image: image_file
        }
      }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']
      expect(data['recipe']['name']).to eq('Test Recipe')
      expect(data['recipe']['image_url']).to be_present
    end

    it 'includes image_url in response JSON' do
      image_file = fixture_file_upload('test_image.png', 'image/png')

      post '/admin/recipes', params: {
        recipe: {
          name: 'Test Recipe',
          description: 'A test recipe',
          source_language: 'en',
          servings_original: 2,
          prep_minutes: 10,
          cook_minutes: 20,
          total_minutes: 30,
          difficulty_level: 'medium',
          image: image_file
        }
      }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']
      expect(data['recipe']).to have_key('image_url')
      expect(data['recipe']['image_url']).to match(%r{^https?://})
    end
  end

  describe 'PUT /admin/recipes/:id with image' do
    let(:recipe) { create(:recipe) }
    let(:new_image_file) { fixture_file_upload('test_image.png', 'image/png') }

    it 'updates recipe image' do
      put "/admin/recipes/#{recipe.id}", params: {
        recipe: {
          name: recipe.name,
          description: recipe.description,
          source_language: recipe.source_language,
          servings_original: recipe.servings_original,
          prep_minutes: recipe.prep_minutes,
          cook_minutes: recipe.cook_minutes,
          total_minutes: recipe.total_minutes,
          difficulty_level: recipe.difficulty_level,
          image: new_image_file
        }
      }

      expect(response).to have_http_status(:ok)
      recipe.reload
      expect(recipe.image).to be_attached
    end

    it 'returns updated image_url in response' do
      put "/admin/recipes/#{recipe.id}", params: {
        recipe: {
          name: recipe.name,
          description: recipe.description,
          source_language: recipe.source_language,
          servings_original: recipe.servings_original,
          prep_minutes: recipe.prep_minutes,
          cook_minutes: recipe.cook_minutes,
          total_minutes: recipe.total_minutes,
          difficulty_level: recipe.difficulty_level,
          image: new_image_file
        }
      }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']
      expect(data['recipe']['image_url']).to be_present
    end
  end

  describe 'GET /admin/recipes/:id' do
    let(:recipe) { create(:recipe) }

    it 'includes image_url in recipe detail' do
      get "/admin/recipes/#{recipe.id}"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']
      expect(data['recipe']).to have_key('image_url')
      expect(data['recipe']['image_url']).to match(%r{^https?://})
    end
  end

  describe 'GET /admin/recipes' do
    before { create(:recipe) }

    it 'includes image_url in recipe list' do
      get '/admin/recipes'

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)['data']
      expect(data['recipes']).not_to be_empty

      recipe_item = data['recipes'].first
      expect(recipe_item).to have_key('image_url')
      expect(recipe_item['image_url']).to match(%r{^https?://})
    end
  end
end
