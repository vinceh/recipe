require 'rails_helper'

RSpec.describe 'Admin::AiPrompts', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  let(:ai_prompt_attributes) do
    {
      prompt_key: 'recipe_parse_text_v1',
      prompt_type: 'system',
      feature_area: 'recipe_parsing',
      prompt_text: 'You are a helpful assistant that parses recipes from text. Extract: {{variables}}',
      description: 'System prompt for recipe text parsing',
      active: true,
      version: 1,
      variables: ['variables']
    }
  end

  describe 'GET /admin/ai_prompts' do
    let!(:system_prompt) { create(:ai_prompt, prompt_key: 'sys1', prompt_type: 'system', feature_area: 'recipe_parsing', prompt_text: 'System prompt') }
    let!(:user_prompt) { create(:ai_prompt, prompt_key: 'user1', prompt_type: 'user', feature_area: 'recipe_parsing', prompt_text: 'User prompt') }
    let!(:inactive_prompt) { create(:ai_prompt, prompt_key: 'inactive1', prompt_type: 'system', feature_area: 'recipe_parsing', prompt_text: 'Inactive', active: false) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'lists all AI prompts' do
        get '/admin/ai_prompts', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ai_prompts'].length).to eq(3)
      end

      it 'filters by prompt_type' do
        get '/admin/ai_prompts', params: { prompt_type: 'system' }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['ai_prompts'].length).to eq(2)
        expect(json['data']['ai_prompts'].all? { |p| p['prompt_type'] == 'system' }).to be true
      end

      it 'filters by active status' do
        get '/admin/ai_prompts', params: { active: 'true' }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['ai_prompts'].length).to eq(2)
        expect(json['data']['ai_prompts'].all? { |p| p['active'] == true }).to be true
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'returns forbidden' do
        get '/admin/ai_prompts', headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /admin/ai_prompts/:id' do
    let!(:prompt) { create(:ai_prompt, ai_prompt_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'shows AI prompt details' do
        get "/admin/ai_prompts/#{prompt.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ai_prompt']['prompt_key']).to eq('recipe_parse_text_v1')
        expect(json['data']['ai_prompt']['feature_area']).to eq('recipe_parsing')
      end
    end
  end

  describe 'POST /admin/ai_prompts' do
    context 'AC-ADMIN-014: AI prompt CRUD' do
      before { sign_in admin_user }

      it 'creates a new AI prompt' do
        post '/admin/ai_prompts',
             params: { ai_prompt: ai_prompt_attributes }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ai_prompt']['prompt_key']).to eq('recipe_parse_text_v1')
        expect(json['message']).to eq('AI prompt created successfully')
      end

      it 'validates required fields' do
        post '/admin/ai_prompts',
             params: { ai_prompt: { prompt_key: 'test123' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end
  end

  describe 'PUT /admin/ai_prompts/:id' do
    let!(:prompt) { create(:ai_prompt, ai_prompt_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'updates the AI prompt' do
        put "/admin/ai_prompts/#{prompt.id}",
            params: { ai_prompt: { prompt_text: 'Updated content: {{new_vars}}' } }.to_json,
            headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ai_prompt']['prompt_text']).to eq('Updated content: {{new_vars}}')
        expect(json['message']).to eq('AI prompt updated successfully')

        prompt.reload
        expect(prompt.prompt_text).to eq('Updated content: {{new_vars}}')
      end
    end
  end

  describe 'DELETE /admin/ai_prompts/:id' do
    let!(:prompt) { create(:ai_prompt, ai_prompt_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'deletes the AI prompt' do
        delete "/admin/ai_prompts/#{prompt.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['deleted']).to be true
        expect(json['message']).to eq('AI prompt deleted successfully')

        expect(AiPrompt.find_by(id: prompt.id)).to be_nil
      end
    end
  end

  describe 'POST /admin/ai_prompts/:id/activate' do
    let!(:prompt1) { create(:ai_prompt, prompt_key: 'key1', prompt_type: 'system', feature_area: 'recipe_parsing', prompt_text: 'Prompt 1', active: true) }
    let!(:prompt2) { create(:ai_prompt, prompt_key: 'key2', prompt_type: 'system', feature_area: 'recipe_parsing', prompt_text: 'Prompt 2', active: false) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'activates the prompt and deactivates others of the same type' do
        post "/admin/ai_prompts/#{prompt2.id}/activate", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['ai_prompt']['active']).to be true
        expect(json['message']).to eq('AI prompt activated successfully')

        prompt1.reload
        prompt2.reload
        expect(prompt1.active).to be false
        expect(prompt2.active).to be true
      end
    end
  end

  describe 'POST /admin/ai_prompts/:id/test' do
    let!(:prompt) { create(:ai_prompt, ai_prompt_attributes) }

    context 'AC-ADMIN-015: Test AI prompt with sample data' do
      before { sign_in admin_user }

      it 'tests the prompt with sample variables' do
        post "/admin/ai_prompts/#{prompt.id}/test",
             params: { test_variables: { variables: 'name, ingredients, steps' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['original_content']).to include('{{variables}}')
        expect(json['data']['test_content']).to include('name, ingredients, steps')
        expect(json['data']['test_content']).not_to include('{{variables}}')
        expect(json['message']).to eq('Prompt test generated successfully')
      end

      it 'works without test variables' do
        post "/admin/ai_prompts/#{prompt.id}/test",
             params: {}.to_json,
             headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['original_content']).to eq(prompt.prompt_text)
      end
    end
  end
end
