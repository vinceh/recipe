require 'rails_helper'

RSpec.describe 'Api::V1::DataReferences', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }

  before do
    # Create some test data references
    DataReference.create!(reference_type: 'dietary_tag', key: 'vegetarian', display_name: 'Vegetarian')
    DataReference.create!(reference_type: 'dietary_tag', key: 'vegan', display_name: 'Vegan')
    DataReference.create!(reference_type: 'dish_type', key: 'main-course', display_name: 'Main Course')
    DataReference.create!(reference_type: 'dish_type', key: 'dessert', display_name: 'Dessert')
    DataReference.create!(reference_type: 'cuisine', key: 'italian', display_name: 'Italian')
    DataReference.create!(reference_type: 'cuisine', key: 'japanese', display_name: 'Japanese')
    DataReference.create!(reference_type: 'recipe_type', key: 'quick-weeknight', display_name: 'Quick Weeknight')
  end

  describe 'GET /api/v1/data_references' do
    it 'returns all reference data grouped by category' do
      get '/api/v1/data_references', headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['success']).to be true
      expect(json['data']).to have_key('dietary_tags')
      expect(json['data']).to have_key('dish_types')
      expect(json['data']).to have_key('cuisines')
      expect(json['data']).to have_key('recipe_types')

      # Check dietary tags
      dietary_tags = json['data']['dietary_tags']
      expect(dietary_tags.length).to eq(2)
      expect(dietary_tags).to include(
        { 'key' => 'vegetarian', 'display_name' => 'Vegetarian' }
      )

      # Check dish types
      dish_types = json['data']['dish_types']
      expect(dish_types.length).to eq(2)

      # Check cuisines
      cuisines = json['data']['cuisines']
      expect(cuisines.length).to eq(2)

      # Check recipe types
      recipe_types = json['data']['recipe_types']
      expect(recipe_types.length).to eq(1)
    end

    it 'filters by category when provided' do
      get '/api/v1/data_references', params: { category: 'dietary_tags' }, headers: headers

      json = JSON.parse(response.body)

      expect(json['data']).to have_key('dietary_tags')
      expect(json['data']).not_to have_key('dish_types')
      expect(json['data']).not_to have_key('cuisines')
      expect(json['data']['dietary_tags'].length).to eq(2)
    end

    it 'returns error for invalid category' do
      get '/api/v1/data_references', params: { category: 'invalid_category' }, headers: headers

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['success']).to be false
      expect(json['message']).to include('Invalid category')
    end

    it 'does not require authentication' do
      get '/api/v1/data_references', headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
