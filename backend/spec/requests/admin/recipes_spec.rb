require 'rails_helper'

RSpec.describe 'Admin::Recipes', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  let(:recipe_attributes) do
    {
      name: 'Test Recipe',
      source_language: 'en',
      servings_original: 4,
      servings_min: 2,
      servings_max: 8,
      prep_minutes: 10,
      cook_minutes: 20,
      total_minutes: 30
    }
  end

  describe 'GET /admin/recipes' do
    let!(:recipe1) { Recipe.create!(recipe_attributes) }
    let!(:recipe2) { Recipe.create!(recipe_attributes.merge(name: 'Another Recipe')) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'lists all recipes' do
        get '/admin/recipes', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['recipes'].length).to eq(2)
      end

      it 'filters by name search' do
        get '/admin/recipes', params: { q: 'Another' }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['recipes'].length).to eq(1)
        expect(json['data']['recipes'][0]['name']).to eq('Another Recipe')
      end

      it 'filters by cuisine' do
        get '/admin/recipes', params: { cuisine: 'italian' }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['recipes'].length).to eq(2)
      end

      it 'includes admin-specific fields' do
        get '/admin/recipes', headers: headers

        json = JSON.parse(response.body)
        recipe_json = json['data']['recipes'].first

        expect(recipe_json).to have_key('admin_notes')
        expect(recipe_json).to have_key('translations_completed')
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'returns forbidden' do
        get '/admin/recipes', headers: headers

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Admin access required')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get '/admin/recipes', headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /admin/recipes' do
    context 'AC-ADMIN-001: Manual recipe creation' do
      before { sign_in admin_user }

      it 'creates a new recipe' do
        post '/admin/recipes',
             params: { recipe: recipe_attributes }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['recipe']['name']).to eq('Test Recipe')
        expect(json['message']).to eq('Recipe created successfully')
      end

      it 'validates required fields' do
        post '/admin/recipes',
             params: { recipe: { language: 'en' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'returns forbidden' do
        post '/admin/recipes',
             params: { recipe: recipe_attributes }.to_json,
             headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT /admin/recipes/:id' do
    let!(:recipe) { Recipe.create!(recipe_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'updates the recipe' do
        put "/admin/recipes/#{recipe.id}",
            params: { recipe: { name: 'Updated Name' } }.to_json,
            headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['recipe']['name']).to eq('Updated Name')
        expect(json['message']).to eq('Recipe updated successfully')

        recipe.reload
        expect(recipe.name).to eq('Updated Name')
      end

      it 'validates updates' do
        put "/admin/recipes/#{recipe.id}",
            params: { recipe: { name: '' } }.to_json,
            headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'returns forbidden' do
        put "/admin/recipes/#{recipe.id}",
            params: { recipe: { name: 'Hacked' } }.to_json,
            headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /admin/recipes/:id' do
    let!(:recipe) { Recipe.create!(recipe_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'deletes the recipe' do
        delete "/admin/recipes/#{recipe.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['deleted']).to be true
        expect(json['message']).to eq('Recipe deleted successfully')

        expect(Recipe.find_by(id: recipe.id)).to be_nil
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'returns forbidden' do
        delete "/admin/recipes/#{recipe.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /admin/recipes/parse_text' do
    context 'AC-ADMIN-002: Text block import' do
      before { sign_in admin_user }

      it 'parses recipe from text' do
        # Mock the parser service
        mock_parser = instance_double(RecipeParserService)
        allow(RecipeParserService).to receive(:new).and_return(mock_parser)
        allow(mock_parser).to receive(:parse_text_block).and_return({
          'name' => 'Parsed Recipe',
          'language' => 'en',
          'ingredient_groups' => [],
          'steps' => []
        })

        post '/admin/recipes/parse_text',
             params: { text_content: 'Recipe text here...' }.to_json,
             headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['recipe_data']['name']).to eq('Parsed Recipe')
      end

      it 'handles parse failures' do
        mock_parser = instance_double(RecipeParserService)
        allow(RecipeParserService).to receive(:new).and_return(mock_parser)
        allow(mock_parser).to receive(:parse_text_block).and_return(nil)

        post '/admin/recipes/parse_text',
             params: { text_content: 'Invalid text' }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end
  end

  describe 'POST /admin/recipes/parse_url' do
    context 'AC-ADMIN-003: URL import' do
      before { sign_in admin_user }

      it 'parses recipe from URL' do
        # Mock the parser service
        mock_parser = instance_double(RecipeParserService)
        allow(RecipeParserService).to receive(:new).and_return(mock_parser)
        allow(mock_parser).to receive(:parse_url).and_return({
          'name' => 'URL Recipe',
          'language' => 'en',
          'source_url' => 'https://example.com/recipe',
          'ingredient_groups' => [],
          'steps' => []
        })

        post '/admin/recipes/parse_url',
             params: { url: 'https://example.com/recipe' }.to_json,
             headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['recipe_data']['name']).to eq('URL Recipe')
      end

      it 'handles URL fetch errors' do
        # Mock the parser service to raise an error
        mock_parser = instance_double(RecipeParserService)
        allow(RecipeParserService).to receive(:new).and_return(mock_parser)
        allow(mock_parser).to receive(:parse_url)
          .and_raise(StandardError.new('Connection failed'))

        post '/admin/recipes/parse_url',
             params: { url: 'https://invalid.com' }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Connection failed')
      end
    end
  end

  describe 'POST /admin/recipes/parse_image' do
    context 'AC-ADMIN-004: Image import' do
      before { sign_in admin_user }

      it 'parses recipe from image URL' do
        # Mock the parser service
        mock_parser = instance_double(RecipeParserService)
        allow(RecipeParserService).to receive(:new).and_return(mock_parser)
        allow(mock_parser).to receive(:parse_image).and_return({
          'name' => 'Image Recipe',
          'language' => 'en',
          'ingredient_groups' => [],
          'steps' => []
        })

        post '/admin/recipes/parse_image',
             params: { image_url: 'https://example.com/recipe.jpg' }.to_json,
             headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['recipe_data']['name']).to eq('Image Recipe')
      end

      it 'requires image_url or image_file' do
        post '/admin/recipes/parse_image',
             params: {}.to_json,
             headers: headers

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Image file or URL required')
      end
    end
  end

  describe 'POST /admin/recipes/check_duplicates' do
    context 'AC-ADMIN-005 & AC-ADMIN-006: Duplicate detection' do
      before { sign_in admin_user }

      let!(:existing_recipe) do
        recipe = Recipe.create!(recipe_attributes.merge(name: 'Pad Thai'))
        recipe.recipe_aliases.create!(alias_name: 'Thai noodles')
        recipe.recipe_aliases.create!(alias_name: 'Phad Thai')
        recipe
      end

      it 'finds similar recipes by name' do
        post '/admin/recipes/check_duplicates',
             params: { name: 'Pad Thai' }.to_json,
             headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['has_duplicates']).to be true
        expect(json['data']['similar_recipes'].length).to eq(1)
        expect(json['data']['similar_recipes'][0]['name']).to eq('Pad Thai')
      end

      it 'finds similar recipes by alias' do
        post '/admin/recipes/check_duplicates',
             params: { name: 'New Recipe', aliases: ['Thai noodles'] }.to_json,
             headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data']['has_duplicates']).to be true
        expect(json['data']['similar_recipes'][0]['name']).to eq('Pad Thai')
      end

      it 'returns no duplicates when none found' do
        post '/admin/recipes/check_duplicates',
             params: { name: 'Completely Unique Recipe' }.to_json,
             headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['has_duplicates']).to be false
        expect(json['data']['similar_recipes']).to be_empty
      end
    end
  end

  describe 'DELETE /admin/recipes/bulk_delete' do
    context 'AC-ADMIN-009: Bulk delete' do
      before { sign_in admin_user }

      let!(:recipe1) { Recipe.create!(recipe_attributes) }
      let!(:recipe2) { Recipe.create!(recipe_attributes.merge(name: 'Recipe 2')) }
      let!(:recipe3) { Recipe.create!(recipe_attributes.merge(name: 'Recipe 3')) }

      it 'deletes multiple recipes' do
        delete '/admin/recipes/bulk_delete',
               params: { recipe_ids: [recipe1.id, recipe2.id] }.to_json,
               headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['deleted_count']).to eq(2)
        expect(json['message']).to eq('2 recipe(s) deleted successfully')

        expect(Recipe.find_by(id: recipe1.id)).to be_nil
        expect(Recipe.find_by(id: recipe2.id)).to be_nil
        expect(Recipe.find_by(id: recipe3.id)).to be_present
      end

      it 'requires recipe_ids array' do
        delete '/admin/recipes/bulk_delete',
               params: { recipe_ids: 'not-an-array' }.to_json,
               headers: headers

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'POST /admin/recipes/:id/regenerate_translations' do
    context 'AC-ADMIN-008: Regenerate translations' do
      before { sign_in admin_user }

      let!(:recipe) { Recipe.create!(recipe_attributes.merge(translations_completed: true)) }

      it 'queues translation regeneration' do
        post "/admin/recipes/#{recipe.id}/regenerate_translations", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['message']).to eq('Translation regeneration queued')

        recipe.reload
        expect(recipe.translations_completed).to be false
      end
    end
  end

  describe 'POST /admin/recipes with nested attributes' do
    context 'AC-PHASE2-STEP6-005: Create recipe with nested ingredient_groups and recipe_ingredients' do
      let(:admin_auth_token) do
        post '/api/v1/auth/sign_in',
             params: { user: { email: admin_user.email, password: 'password123' } }.to_json,
             headers: headers
        response.headers['Authorization']
      end

      it 'creates recipe with nested ingredient_groups and recipe_ingredients' do
        params = recipe_attributes.merge({
          ingredient_groups_attributes: [
            {
              name: 'Dry Ingredients',
              position: 1,
              recipe_ingredients_attributes: [
                { ingredient_name: 'flour', amount: 2, unit: 'cup', position: 1 },
                { ingredient_name: 'sugar', amount: 0.5, unit: 'cup', position: 2 }
              ]
            },
            {
              name: 'Wet Ingredients',
              position: 2,
              recipe_ingredients_attributes: [
                { ingredient_name: 'milk', amount: 1, unit: 'cup', position: 1 }
              ]
            }
          ]
        })

        post '/admin/recipes',
             params: { recipe: params }.to_json,
             headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        recipe = Recipe.last
        expect(recipe.ingredient_groups.count).to eq(2)
        expect(recipe.ingredient_groups.first.name).to eq('Dry Ingredients')
        expect(recipe.ingredient_groups.first.recipe_ingredients.count).to eq(2)
        expect(recipe.ingredient_groups.last.recipe_ingredients.count).to eq(1)
      end

      it 'creates recipe with nested recipe_steps' do
        params = recipe_attributes.merge({
          recipe_steps_attributes: [
            { step_number: 1, instruction_original: 'Mix dry ingredients' },
            { step_number: 2, instruction_original: 'Add wet ingredients' },
            { step_number: 3, instruction_original: 'Bake at 350F' }
          ]
        })

        post '/admin/recipes',
             params: { recipe: params }.to_json,
             headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        recipe = Recipe.last
        expect(recipe.recipe_steps.count).to eq(3)
        expect(recipe.recipe_steps.map(&:step_number)).to eq([1, 2, 3])
        expect(recipe.recipe_steps.first.instruction_original).to eq('Mix dry ingredients')
      end

      it 'creates recipe with both nested ingredient_groups and recipe_steps' do
        params = recipe_attributes.merge({
          ingredient_groups_attributes: [
            {
              name: 'Main Ingredients',
              position: 1,
              recipe_ingredients_attributes: [
                { ingredient_name: 'chicken', amount: 2, unit: 'lb', position: 1 }
              ]
            }
          ],
          recipe_steps_attributes: [
            { step_number: 1, instruction_original: 'Prepare chicken' },
            { step_number: 2, instruction_original: 'Cook chicken' }
          ]
        })

        post '/admin/recipes',
             params: { recipe: params }.to_json,
             headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:created)
        recipe = Recipe.last
        expect(recipe.ingredient_groups.count).to eq(1)
        expect(recipe.recipe_steps.count).to eq(2)
      end

      it 'rejects empty nested attributes' do
        params = recipe_attributes.merge({
          ingredient_groups_attributes: [
            {
              name: 'Dry Ingredients',
              position: 1,
              recipe_ingredients_attributes: [
                {} # Empty - should be rejected by reject_if
              ]
            }
          ]
        })

        post '/admin/recipes',
             params: { recipe: params }.to_json,
             headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:created)
        recipe = Recipe.last
        expect(recipe.ingredient_groups.first.recipe_ingredients.count).to eq(0)
      end

      it 'validates nested ingredient_groups required fields' do
        params = recipe_attributes.merge({
          ingredient_groups_attributes: [
            {
              position: 1,
              recipe_ingredients_attributes: []
              # Missing name - should fail validation
            }
          ]
        })

        post '/admin/recipes',
             params: { recipe: params }.to_json,
             headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end

      it 'validates nested recipe_ingredients required fields' do
        params = recipe_attributes.merge({
          ingredient_groups_attributes: [
            {
              name: 'Ingredients',
              position: 1,
              recipe_ingredients_attributes: [
                { amount: 1, unit: 'cup', position: 1 }
                # Missing ingredient_name - should fail validation
              ]
            }
          ]
        })

        post '/admin/recipes',
             params: { recipe: params }.to_json,
             headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /admin/recipes/:id with nested attributes' do
    context 'AC-PHASE2-STEP6-016: Update recipe with nested attributes' do
      let(:admin_auth_token) do
        post '/api/v1/auth/sign_in',
             params: { user: { email: admin_user.email, password: 'password123' } }.to_json,
             headers: headers
        response.headers['Authorization']
      end

      let!(:recipe) { Recipe.create!(recipe_attributes) }

      it 'updates recipe and adds nested ingredient_groups' do
        params = {
          ingredient_groups_attributes: [
            {
              name: 'New Group',
              position: 1,
              recipe_ingredients_attributes: [
                { ingredient_name: 'salt', amount: 1, unit: 'tsp', position: 1 }
              ]
            }
          ]
        }

        put "/admin/recipes/#{recipe.id}",
            params: { recipe: params }.to_json,
            headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true

        recipe.reload
        expect(recipe.ingredient_groups.count).to eq(1)
        expect(recipe.ingredient_groups.first.name).to eq('New Group')
      end

      it 'updates nested ingredient_groups' do
        group = recipe.ingredient_groups.create!(name: 'Original Group', position: 1)
        ingredient = group.recipe_ingredients.create!(
          ingredient_name: 'flour',
          amount: 2,
          unit: 'cup',
          position: 1
        )

        params = {
          ingredient_groups_attributes: [
            {
              id: group.id,
              name: 'Updated Group',
              position: 1,
              recipe_ingredients_attributes: [
                {
                  id: ingredient.id,
                  ingredient_name: 'sugar',
                  amount: 1,
                  unit: 'cup',
                  position: 1
                }
              ]
            }
          ]
        }

        put "/admin/recipes/#{recipe.id}",
            params: { recipe: params }.to_json,
            headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:ok)
        group.reload
        expect(group.name).to eq('Updated Group')
        expect(group.recipe_ingredients.first.ingredient_name).to eq('sugar')
      end

      it 'deletes nested ingredient_groups via _destroy flag' do
        group = recipe.ingredient_groups.create!(name: 'To Delete', position: 1)

        params = {
          ingredient_groups_attributes: [
            {
              id: group.id,
              _destroy: true
            }
          ]
        }

        put "/admin/recipes/#{recipe.id}",
            params: { recipe: params }.to_json,
            headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:ok)
        expect(recipe.ingredient_groups.count).to eq(0)
        expect(IngredientGroup.find_by(id: group.id)).to be_nil
      end

      it 'deletes nested recipe_ingredients via _destroy flag' do
        group = recipe.ingredient_groups.create!(name: 'Group', position: 1)
        ingredient = group.recipe_ingredients.create!(
          ingredient_name: 'flour',
          amount: 2,
          unit: 'cup',
          position: 1
        )

        params = {
          ingredient_groups_attributes: [
            {
              id: group.id,
              name: 'Group',
              position: 1,
              recipe_ingredients_attributes: [
                {
                  id: ingredient.id,
                  _destroy: true
                }
              ]
            }
          ]
        }

        put "/admin/recipes/#{recipe.id}",
            params: { recipe: params }.to_json,
            headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:ok)
        group.reload
        expect(group.recipe_ingredients.count).to eq(0)
      end

      it 'adds and deletes recipe_steps in same update' do
        step = recipe.recipe_steps.create!(step_number: 1, instruction_original: 'Original step')

        params = {
          recipe_steps_attributes: [
            {
              id: step.id,
              _destroy: true
            },
            {
              step_number: 2,
              instruction_original: 'New step'
            }
          ]
        }

        put "/admin/recipes/#{recipe.id}",
            params: { recipe: params }.to_json,
            headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:ok)
        recipe.reload
        expect(recipe.recipe_steps.count).to eq(1)
        expect(recipe.recipe_steps.first.step_number).to eq(2)
      end

      it 'propagates validation errors from nested attributes' do
        group = recipe.ingredient_groups.create!(name: 'Group', position: 1)

        params = {
          ingredient_groups_attributes: [
            {
              id: group.id,
              name: '',
              position: 1
              # Empty name - should fail validation
            }
          ]
        }

        put "/admin/recipes/#{recipe.id}",
            params: { recipe: params }.to_json,
            headers: headers.merge('Authorization' => admin_auth_token)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end
  end
end
