require 'rails_helper'

RSpec.describe 'Api::V1::Notes', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:recipe) do
    Recipe.create!(
      name: 'Test Recipe',
      language: 'en',
      servings: { 'original' => 4, 'min' => 2, 'max' => 8 },
      timing: { 'prep_minutes' => 10, 'cook_minutes' => 20, 'total_minutes' => 30 },
      ingredient_groups: [],
      steps: [
        { 'id' => 'step-001', 'order' => 1, 'instructions' => { 'original' => 'Mix ingredients' } }
      ]
    )
  end

  describe 'POST /api/v1/recipes/:recipe_id/notes' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'creates a recipe note' do
        post "/api/v1/recipes/#{recipe.id}/notes",
             params: {
               note_type: 'recipe',
               note_text: 'This is a great recipe!'
             }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['note']['note_type']).to eq('recipe')
        expect(json['data']['note']['note_text']).to eq('This is a great recipe!')
        expect(json['message']).to eq('Note created successfully')
      end

      it 'creates a step-specific note' do
        post "/api/v1/recipes/#{recipe.id}/notes",
             params: {
               note_type: 'step',
               note_target_id: 'step-001',
               note_text: 'Mix for 2 minutes'
             }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['data']['note']['note_type']).to eq('step')
        expect(json['data']['note']['note_target_id']).to eq('step-001')
        expect(json['data']['note']['note_text']).to eq('Mix for 2 minutes')
      end

      it 'requires note_type' do
        post "/api/v1/recipes/#{recipe.id}/notes",
             params: { note_text: 'Test' }.to_json,
             headers: headers

        expect(response).to have_http_status(:bad_request)
      end

      it 'requires note_text' do
        post "/api/v1/recipes/#{recipe.id}/notes",
             params: { note_type: 'recipe' }.to_json,
             headers: headers

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        post "/api/v1/recipes/#{recipe.id}/notes",
             params: { note_type: 'recipe', note_text: 'Test' }.to_json,
             headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /api/v1/notes/:id' do
    let(:note) { user.user_recipe_notes.create!(recipe: recipe, note_type: 'recipe', note_text: 'Original text') }

    context 'when user is authenticated and owns the note' do
      before { sign_in user }

      it 'updates the note text' do
        put "/api/v1/notes/#{note.id}",
            params: { note_text: 'Updated text' }.to_json,
            headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['note']['note_text']).to eq('Updated text')
        expect(json['message']).to eq('Note updated successfully')

        note.reload
        expect(note.note_text).to eq('Updated text')
      end

      it 'requires note_text parameter' do
        put "/api/v1/notes/#{note.id}",
            params: {}.to_json,
            headers: headers

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when user tries to update another user\'s note' do
      before { sign_in other_user }

      it 'returns not found' do
        put "/api/v1/notes/#{note.id}",
            params: { note_text: 'Hacked' }.to_json,
            headers: headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['message']).to include('not found or you do not have permission')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        put "/api/v1/notes/#{note.id}",
            params: { note_text: 'Updated' }.to_json,
            headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/notes/:id' do
    let(:note) { user.user_recipe_notes.create!(recipe: recipe, note_type: 'recipe', note_text: 'Test note') }

    context 'when user is authenticated and owns the note' do
      before { sign_in user }

      it 'deletes the note' do
        delete "/api/v1/notes/#{note.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['deleted']).to be true
        expect(json['message']).to eq('Note deleted successfully')

        expect(UserRecipeNote.find_by(id: note.id)).to be_nil
      end
    end

    context 'when user tries to delete another user\'s note' do
      before { sign_in other_user }

      it 'returns not found' do
        delete "/api/v1/notes/#{note.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        delete "/api/v1/notes/#{note.id}", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/recipes/:recipe_id/notes' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'returns all notes for the recipe (user-specific)' do
        note1 = user.user_recipe_notes.create!(recipe: recipe, note_type: 'recipe', note_text: 'Note 1')
        note2 = user.user_recipe_notes.create!(recipe: recipe, note_type: 'step', note_target_id: 'step-001', note_text: 'Note 2')

        # Other user's note should not appear
        other_user.user_recipe_notes.create!(recipe: recipe, note_type: 'recipe', note_text: 'Other note')

        get "/api/v1/recipes/#{recipe.id}/notes", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['notes'].length).to eq(2)

        note_texts = json['data']['notes'].map { |n| n['note_text'] }
        expect(note_texts).to contain_exactly('Note 1', 'Note 2')
        expect(note_texts).not_to include('Other note')
      end

      it 'returns empty array when no notes exist' do
        get "/api/v1/recipes/#{recipe.id}/notes", headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['notes']).to eq([])
      end

      it 'orders notes by most recent first' do
        note1 = user.user_recipe_notes.create!(recipe: recipe, note_type: 'recipe', note_text: 'First')
        sleep(0.01)
        note2 = user.user_recipe_notes.create!(recipe: recipe, note_type: 'recipe', note_text: 'Second')

        get "/api/v1/recipes/#{recipe.id}/notes", headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['notes'][0]['note_text']).to eq('Second')
        expect(json['data']['notes'][1]['note_text']).to eq('First')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized' do
        get "/api/v1/recipes/#{recipe.id}/notes", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
