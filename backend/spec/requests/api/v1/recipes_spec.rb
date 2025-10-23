require 'rails_helper'

RSpec.describe 'Api::V1::Recipes', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }

  describe 'GET /api/v1/recipes' do
    context 'with no recipes' do
      it 'returns empty list' do
        get '/api/v1/recipes', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['recipes']).to eq([])
        expect(json['data']['pagination']['total_count']).to eq(0)
      end
    end

    context 'with multiple recipes' do
      let!(:recipe1) do
        Recipe.create!(
          name: 'Spaghetti Carbonara',
          language: 'en',
          servings: { 'original' => 4, 'min' => 2, 'max' => 8 },
          timing: { 'prep_minutes' => 10, 'cook_minutes' => 20, 'total_minutes' => 30 },
          dietary_tags: ['vegetarian'],
          cuisines: ['italian'],
          dish_types: ['main-course'],
          ingredient_groups: [
            {
              'name' => 'Main',
              'items' => [
                { 'name' => 'spaghetti', 'amount' => '400', 'unit' => 'g' }
              ]
            }
          ],
          steps: [
            { 'id' => 'step-001', 'order' => 1, 'instructions' => { 'original' => 'Boil pasta' } }
          ]
        )
      end

      let!(:recipe2) do
        Recipe.create!(
          name: 'Chicken Curry',
          language: 'en',
          servings: { 'original' => 6, 'min' => 4, 'max' => 8 },
          timing: { 'prep_minutes' => 15, 'cook_minutes' => 30, 'total_minutes' => 45 },
          cuisines: ['indian'],
          dish_types: ['main-course'],
          ingredient_groups: [],
          steps: []
        )
      end

      let!(:recipe3) do
        Recipe.create!(
          name: 'Caesar Salad',
          language: 'en',
          servings: { 'original' => 2, 'min' => 1, 'max' => 4 },
          timing: { 'prep_minutes' => 10, 'cook_minutes' => 0, 'total_minutes' => 10 },
          dietary_tags: ['vegetarian'],
          ingredient_groups: [],
          steps: []
        )
      end

      it 'returns all recipes with pagination' do
        get '/api/v1/recipes', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['recipes'].length).to eq(3)
        expect(json['data']['pagination']['total_count']).to eq(3)
        expect(json['data']['pagination']['current_page']).to eq(1)
        expect(json['data']['pagination']['per_page']).to eq(20)
      end

      it 'supports pagination parameters' do
        get '/api/v1/recipes', params: { page: 1, per_page: 2 }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['recipes'].length).to eq(2)
        expect(json['data']['pagination']['per_page']).to eq(2)
        expect(json['data']['pagination']['total_pages']).to eq(2)
      end

      it 'includes recipe fields in list view' do
        get '/api/v1/recipes', headers: headers

        json = JSON.parse(response.body)
        recipe_json = json['data']['recipes'].first

        expect(recipe_json).to include(
          'id',
          'name',
          'language',
          'servings',
          'timing',
          'dietary_tags',
          'dish_types',
          'cuisines',
          'created_at',
          'updated_at'
        )
      end

      context 'searching' do
        it 'searches by recipe name' do
          get '/api/v1/recipes', params: { q: 'Carbonara' }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(1)
          expect(json['data']['recipes'].first['name']).to eq('Spaghetti Carbonara')
        end

        it 'is case insensitive' do
          get '/api/v1/recipes', params: { q: 'CARBONARA' }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(1)
        end
      end

      context 'filtering by dietary tags' do
        it 'filters by single dietary tag' do
          get '/api/v1/recipes', params: { dietary_tags: 'vegetarian' }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(2)
          names = json['data']['recipes'].map { |r| r['name'] }
          expect(names).to contain_exactly('Spaghetti Carbonara', 'Caesar Salad')
        end
      end

      context 'filtering by cuisines' do
        it 'filters by single cuisine' do
          get '/api/v1/recipes', params: { cuisines: 'italian' }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(1)
          expect(json['data']['recipes'].first['name']).to eq('Spaghetti Carbonara')
        end

        it 'filters by multiple cuisines' do
          get '/api/v1/recipes', params: { cuisines: 'italian,indian' }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(2)
        end
      end

      context 'filtering by dish types' do
        it 'filters by dish type' do
          get '/api/v1/recipes', params: { dish_types: 'main-course' }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(2)
        end
      end

      context 'filtering by timing' do
        it 'filters by max cook time' do
          get '/api/v1/recipes', params: { max_cook_time: 20 }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(2)
          names = json['data']['recipes'].map { |r| r['name'] }
          expect(names).to contain_exactly('Spaghetti Carbonara', 'Caesar Salad')
        end

        it 'filters by max prep time' do
          get '/api/v1/recipes', params: { max_prep_time: 10 }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(2)
        end

        it 'filters by max total time' do
          get '/api/v1/recipes', params: { max_total_time: 30 }, headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(2)
        end
      end

      context 'combining filters' do
        it 'combines dietary tags and cuisine filters' do
          get '/api/v1/recipes',
              params: { dietary_tags: 'vegetarian', cuisines: 'italian' },
              headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(1)
          expect(json['data']['recipes'].first['name']).to eq('Spaghetti Carbonara')
        end

        it 'combines search query and timing filter' do
          get '/api/v1/recipes',
              params: { q: 'a', max_total_time: 30 },
              headers: headers

          json = JSON.parse(response.body)
          expect(json['data']['recipes'].length).to eq(2)
        end
      end
    end
  end

  describe 'GET /api/v1/recipes/:id' do
    let(:recipe) do
      Recipe.create!(
        name: 'Test Recipe',
        language: 'en',
        servings: { 'original' => 4, 'min' => 2, 'max' => 8 },
        timing: { 'prep_minutes' => 10, 'cook_minutes' => 20, 'total_minutes' => 30 },
        equipment: ['oven', 'mixing bowl'],
        dietary_tags: ['vegetarian'],
        cuisines: ['italian'],
        dish_types: ['main-course'],
        recipe_types: ['quick-weeknight'],
        ingredient_groups: [
          {
            'name' => 'Main Ingredients',
            'items' => [
              {
                'name' => 'flour',
                'amount' => '2',
                'unit' => 'cup',
                'preparation' => 'sifted'
              }
            ]
          }
        ],
        steps: [
          {
            'id' => 'step-001',
            'order' => 1,
            'instructions' => {
              'original' => 'Mix ingredients',
              'easier' => 'Combine flour and water',
              'no_equipment' => 'Mix by hand'
            }
          }
        ]
      )
    end

    it 'returns full recipe details' do
      get "/api/v1/recipes/#{recipe.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['success']).to be true
      recipe_json = json['data']['recipe']

      expect(recipe_json['id']).to eq(recipe.id)
      expect(recipe_json['name']).to eq('Test Recipe')
      expect(recipe_json['language']).to eq('en')
    end

    it 'includes servings information' do
      get "/api/v1/recipes/#{recipe.id}", headers: headers

      json = JSON.parse(response.body)
      servings = json['data']['recipe']['servings']

      expect(servings['original']).to eq(4)
      expect(servings['min']).to eq(2)
      expect(servings['max']).to eq(8)
    end

    it 'includes timing information' do
      get "/api/v1/recipes/#{recipe.id}", headers: headers

      json = JSON.parse(response.body)
      timing = json['data']['recipe']['timing']

      expect(timing['prep_minutes']).to eq(10)
      expect(timing['cook_minutes']).to eq(20)
      expect(timing['total_minutes']).to eq(30)
    end

    it 'includes all tags' do
      get "/api/v1/recipes/#{recipe.id}", headers: headers

      json = JSON.parse(response.body)
      recipe_json = json['data']['recipe']

      expect(recipe_json['dietary_tags']).to eq(['vegetarian'])
      expect(recipe_json['cuisines']).to eq(['italian'])
      expect(recipe_json['dish_types']).to eq(['main-course'])
      expect(recipe_json['recipe_types']).to eq(['quick-weeknight'])
    end

    it 'includes ingredient groups with items' do
      get "/api/v1/recipes/#{recipe.id}", headers: headers

      json = JSON.parse(response.body)
      groups = json['data']['recipe']['ingredient_groups']

      expect(groups.length).to eq(1)
      group = groups.first
      expect(group['name']).to eq('Main Ingredients')

      expect(group['items'].length).to eq(1)
      item = group['items'].first
      expect(item['name']).to eq('flour')
      expect(item['amount']).to eq('2')
      expect(item['unit']).to eq('cup')
      expect(item['preparation']).to eq('sifted')
    end

    it 'includes steps with all instruction variants' do
      get "/api/v1/recipes/#{recipe.id}", headers: headers

      json = JSON.parse(response.body)
      steps = json['data']['recipe']['steps']

      expect(steps.length).to eq(1)
      step = steps.first
      expect(step['id']).to eq('step-001')
      expect(step['order']).to eq(1)
      expect(step['instructions']['original']).to eq('Mix ingredients')
      expect(step['instructions']['easier']).to eq('Combine flour and water')
      expect(step['instructions']['no_equipment']).to eq('Mix by hand')
    end

    it 'includes equipment list' do
      get "/api/v1/recipes/#{recipe.id}", headers: headers

      json = JSON.parse(response.body)
      equipment = json['data']['recipe']['equipment']

      expect(equipment).to contain_exactly('oven', 'mixing bowl')
    end

    it 'returns 404 for non-existent recipe' do
      get '/api/v1/recipes/99999999-9999-9999-9999-999999999999', headers: headers

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)

      expect(json['success']).to be false
      expect(json['message']).to eq('Record not found')
    end
  end
end
