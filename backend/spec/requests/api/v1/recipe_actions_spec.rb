require 'rails_helper'

RSpec.describe 'Api::V1::RecipeActions', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }

  let(:recipe) do
    recipe = Recipe.create!(
      name: 'Test Recipe',
      source_language: 'en',
      servings_original: 4,
      servings_min: 2,
      servings_max: 8,
      prep_minutes: 10,
      cook_minutes: 20,
      total_minutes: 30
    )

    group = recipe.ingredient_groups.create!(name: 'Main Ingredients', position: 1)
    group.recipe_ingredients.create!(ingredient_name: 'flour', amount: 2, unit: 'cup', position: 1)
    group.recipe_ingredients.create!(ingredient_name: 'sugar', amount: 100, unit: 'g', position: 2)

    recipe
  end

  describe 'POST /api/v1/recipes/:id/scale' do
    it 'scales recipe ingredients to new serving size' do
      post "/api/v1/recipes/#{recipe.id}/scale",
           params: { servings: 8 }.to_json,
           headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['success']).to be true
      expect(json['data']['original_servings']).to eq(4)
      expect(json['data']['new_servings']).to eq(8)
      expect(json['data']['scale_factor']).to eq(2.0)

      scaled_items = json['data']['scaled_ingredient_groups'][0]['items']
      expect(scaled_items[0]['amount']).to eq('4.0')  # 2 * 2
      expect(scaled_items[1]['amount']).to eq('200.0')  # 100 * 2
    end

    it 'scales down recipe ingredients' do
      post "/api/v1/recipes/#{recipe.id}/scale",
           params: { servings: 2 }.to_json,
           headers: headers

      json = JSON.parse(response.body)
      expect(json['data']['scale_factor']).to eq(0.5)

      scaled_items = json['data']['scaled_ingredient_groups'][0]['items']
      expect(scaled_items[0]['amount']).to eq('1.0')  # 2 * 0.5
      expect(scaled_items[1]['amount']).to eq('50.0')  # 100 * 0.5
    end

    it 'rejects servings below minimum' do
      post "/api/v1/recipes/#{recipe.id}/scale",
           params: { servings: 1 }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['success']).to be false
      expect(json['message']).to include('between 2 and 8')
    end

    it 'rejects servings above maximum' do
      post "/api/v1/recipes/#{recipe.id}/scale",
           params: { servings: 10 }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['message']).to include('between 2 and 8')
    end

    it 'requires servings parameter' do
      post "/api/v1/recipes/#{recipe.id}/scale",
           params: {}.to_json,
           headers: headers

      expect(response).to have_http_status(:bad_request)
    end
  end
end
