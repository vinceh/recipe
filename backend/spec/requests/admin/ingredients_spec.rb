require 'rails_helper'

RSpec.describe 'Admin::Ingredients', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  let(:ingredient_attributes) do
    {
      canonical_name: 'tomato',
      category: 'vegetable'
    }
  end

  let(:nutrition_attributes) do
    {
      calories: 18.0,
      protein_g: 0.9,
      carbs_g: 3.9,
      fat_g: 0.2,
      fiber_g: 1.2,
      data_source: 'usda',
      confidence_score: 0.8
    }
  end

  describe 'GET /admin/ingredients' do
    let!(:tomato) { create(:ingredient, canonical_name: 'tomato', category: 'vegetable') }
    let!(:chicken) { create(:ingredient, canonical_name: 'chicken', category: 'protein') }
    let!(:rice) { create(:ingredient, canonical_name: 'rice', category: 'grain') }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'lists all ingredients' do
        get '/admin/ingredients', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ingredients'].length).to eq(3)
      end

      it 'filters by category' do
        get '/admin/ingredients', params: { category: 'vegetable' }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['ingredients'].length).to eq(1)
        expect(json['data']['ingredients'].first['canonical_name']).to eq('tomato')
      end

      it 'searches by name' do
        get '/admin/ingredients', params: { q: 'tom' }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['ingredients'].length).to eq(1)
        expect(json['data']['ingredients'].first['canonical_name']).to eq('tomato')
      end

      it 'includes pagination' do
        get '/admin/ingredients', headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['pagination']).to be_present
        expect(json['data']['pagination']['current_page']).to eq(1)
        expect(json['data']['pagination']['total_count']).to eq(3)
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'returns forbidden' do
        get '/admin/ingredients', headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /admin/ingredients/:id' do
    let!(:ingredient) { create(:ingredient, ingredient_attributes) }
    let!(:nutrition) { create(:ingredient_nutrition, ingredient: ingredient, **nutrition_attributes) }
    let!(:alias1) { create(:ingredient_alias, ingredient: ingredient, alias: 'tomatoes', language: 'en') }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'shows ingredient details with nutrition and aliases' do
        get "/admin/ingredients/#{ingredient.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ingredient']['canonical_name']).to eq('tomato')
        expect(json['data']['ingredient']['nutrition']).to be_present
        expect(json['data']['ingredient']['nutrition']['calories']).to eq('18.0')
        expect(json['data']['ingredient']['aliases'].length).to eq(1)
        expect(json['data']['ingredient']['aliases'].first['alias']).to eq('tomatoes')
      end
    end
  end

  describe 'POST /admin/ingredients' do
    context 'when user is admin' do
      before { sign_in admin_user }

      it 'creates a new ingredient' do
        post '/admin/ingredients',
             params: { ingredient: ingredient_attributes }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ingredient']['canonical_name']).to eq('tomato')
        expect(json['message']).to eq('Ingredient created successfully')
      end

      it 'creates ingredient with nutrition data' do
        post '/admin/ingredients',
             params: {
               ingredient: ingredient_attributes,
               nutrition: nutrition_attributes
             }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['data']['ingredient']['nutrition']).to be_present
        expect(json['data']['ingredient']['nutrition']['calories']).to eq('18.0')
      end

      it 'creates ingredient with aliases' do
        post '/admin/ingredients',
             params: {
               ingredient: ingredient_attributes,
               aliases: [
                 { alias: 'tomatoes', language: 'en' },
                 { alias: 'tomate', language: 'es' }
               ]
             }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['data']['ingredient']['aliases'].length).to eq(2)
      end

      it 'validates required fields' do
        post '/admin/ingredients',
             params: { ingredient: { category: 'vegetable' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end
  end

  describe 'PUT /admin/ingredients/:id' do
    let!(:ingredient) { create(:ingredient, ingredient_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'updates the ingredient' do
        put "/admin/ingredients/#{ingredient.id}",
            params: { ingredient: { canonical_name: 'roma tomato' } }.to_json,
            headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ingredient']['canonical_name']).to eq('roma tomato')
        expect(json['message']).to eq('Ingredient updated successfully')

        ingredient.reload
        expect(ingredient.canonical_name).to eq('roma tomato')
      end

      it 'updates nutrition data' do
        create(:ingredient_nutrition, ingredient: ingredient, calories: 10.0)

        put "/admin/ingredients/#{ingredient.id}",
            params: { nutrition: { calories: 20.0 } }.to_json,
            headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data']['ingredient']['nutrition']['calories']).to eq('20.0')
      end

      it 'creates nutrition if it does not exist' do
        put "/admin/ingredients/#{ingredient.id}",
            params: { nutrition: nutrition_attributes }.to_json,
            headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data']['ingredient']['nutrition']).to be_present
      end
    end
  end

  describe 'DELETE /admin/ingredients/:id' do
    let!(:ingredient) { create(:ingredient, ingredient_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'deletes the ingredient' do
        delete "/admin/ingredients/#{ingredient.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['deleted']).to be true
        expect(json['message']).to eq('Ingredient deleted successfully')

        expect(Ingredient.find_by(id: ingredient.id)).to be_nil
      end
    end
  end

  describe 'POST /admin/ingredients/:id/refresh_nutrition' do
    context 'AC-NUTR-013: Refresh nutrition data' do
      before { sign_in admin_user }

      let!(:ingredient) { create(:ingredient, ingredient_attributes) }
      let!(:nutrition) { create(:ingredient_nutrition, ingredient: ingredient, data_source: 'usda', confidence_score: 0.5) }

      it 'refreshes nutrition data from Nutritionix' do
        post "/admin/ingredients/#{ingredient.id}/refresh_nutrition", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['message']).to eq('Nutrition data refreshed successfully')

        nutrition.reload
        expect(nutrition.data_source).to eq('nutritionix')
        expect(nutrition.confidence_score).to eq(1.0)
      end

      it 'returns error when no nutrition data exists' do
        ingredient_without_nutrition = create(:ingredient, canonical_name: 'pepper')

        post "/admin/ingredients/#{ingredient_without_nutrition.id}/refresh_nutrition", headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['success']).to be false
        expect(json['errors']).to include('Create nutrition data first')
      end
    end
  end
end
