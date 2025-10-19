require 'rails_helper'

RSpec.describe 'Api::V1::Favorites', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }
  let(:user) { create(:user) }

  let(:recipe1) do
    Recipe.create!(
      name: 'Recipe 1',
      language: 'en',
      servings: { 'original' => 4, 'min' => 2, 'max' => 8 },
      timing: { 'prep_minutes' => 10, 'cook_minutes' => 20, 'total_minutes' => 30 },
      ingredient_groups: [],
      steps: []
    )
  end

  let(:recipe2) do
    Recipe.create!(
      name: 'Recipe 2',
      language: 'en',
      servings: { 'original' => 2, 'min' => 1, 'max' => 4 },
      timing: { 'prep_minutes' => 5, 'cook_minutes' => 10, 'total_minutes' => 15 },
      ingredient_groups: [],
      steps: []
    )
  end

  describe 'POST /api/v1/recipes/:id/favorite' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'adds recipe to favorites' do
        post "/api/v1/recipes/#{recipe1.id}/favorite", headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['favorited']).to be true
        expect(json['message']).to eq('Recipe added to favorites')

        expect(user.favorite_recipes).to include(recipe1)
      end

      it 'returns success if already favorited' do
        user.user_favorites.create!(recipe: recipe1)

        post "/api/v1/recipes/#{recipe1.id}/favorite", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Recipe already in favorites')
      end

      it 'returns 404 for non-existent recipe' do
        post "/api/v1/recipes/99999999-9999-9999-9999-999999999999/favorite", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        post "/api/v1/recipes/#{recipe1.id}/favorite", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/recipes/:id/favorite' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'removes recipe from favorites' do
        user.user_favorites.create!(recipe: recipe1)

        delete "/api/v1/recipes/#{recipe1.id}/favorite", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['favorited']).to be false
        expect(json['message']).to eq('Recipe removed from favorites')

        expect(user.favorite_recipes).not_to include(recipe1)
      end

      it 'returns 404 if not in favorites' do
        delete "/api/v1/recipes/#{recipe1.id}/favorite", headers: headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Recipe not in favorites')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        delete "/api/v1/recipes/#{recipe1.id}/favorite", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/users/me/favorites' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'returns empty list when no favorites' do
        get '/api/v1/users/me/favorites', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['favorites']).to eq([])
        expect(json['data']['pagination']['total_count']).to eq(0)
      end

      it 'returns user favorites with pagination' do
        fav1 = user.user_favorites.create!(recipe: recipe1)
        fav2 = user.user_favorites.create!(recipe: recipe2)

        get '/api/v1/users/me/favorites', headers: headers

        json = JSON.parse(response.body)

        expect(json['data']['favorites'].length).to eq(2)
        expect(json['data']['pagination']['total_count']).to eq(2)

        # Check favorited_at is included
        expect(json['data']['favorites'][0]).to have_key('favorited_at')
      end

      it 'supports pagination' do
        5.times do |i|
          recipe = Recipe.create!(
            name: "Recipe #{i}",
            language: 'en',
            servings: { 'original' => 4, 'min' => 2, 'max' => 8 },
            timing: { 'prep_minutes' => 10, 'cook_minutes' => 20, 'total_minutes' => 30 },
            ingredient_groups: [],
            steps: []
          )
          user.user_favorites.create!(recipe: recipe)
        end

        get '/api/v1/users/me/favorites', params: { page: 1, per_page: 3 }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['favorites'].length).to eq(3)
        expect(json['data']['pagination']['total_pages']).to eq(2)
      end

      it 'orders favorites by most recent first' do
        fav1 = user.user_favorites.create!(recipe: recipe1)
        sleep(0.01)
        fav2 = user.user_favorites.create!(recipe: recipe2)

        get '/api/v1/users/me/favorites', headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['favorites'][0]['name']).to eq('Recipe 2')
        expect(json['data']['favorites'][1]['name']).to eq('Recipe 1')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/users/me/favorites', headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
