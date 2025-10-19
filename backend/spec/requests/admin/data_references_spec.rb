require 'rails_helper'

RSpec.describe 'Admin::DataReferences', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  let(:data_reference_attributes) do
    {
      reference_type: 'dietary_tag',
      key: 'test-tag',
      display_name: 'Test Tag',
      active: true,
      sort_order: 10,
      metadata: { color: '#FF0000' }
    }
  end

  describe 'GET /admin/data_references' do
    let!(:dietary_tag) { create(:data_reference, reference_type: 'dietary_tag', key: 'vegan', display_name: 'Vegan') }
    let!(:cuisine) { create(:data_reference, reference_type: 'cuisine', key: 'italian', display_name: 'Italian') }
    let!(:inactive_tag) { create(:data_reference, reference_type: 'dietary_tag', key: 'old-tag', display_name: 'Old Tag', active: false) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'lists all data references' do
        get '/admin/data_references', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['data_references'].length).to eq(3)
      end

      it 'filters by reference_type' do
        get '/admin/data_references', params: { reference_type: 'dietary_tag' }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['data_references'].length).to eq(2)
        expect(json['data']['data_references'].all? { |dr| dr['reference_type'] == 'dietary_tag' }).to be true
      end

      it 'filters by active status' do
        get '/admin/data_references', params: { active: 'true' }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['data_references'].length).to eq(2)
        expect(json['data']['data_references'].all? { |dr| dr['active'] == true }).to be true
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'returns forbidden' do
        get '/admin/data_references', headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /admin/data_references/:id' do
    let!(:data_ref) { create(:data_reference, data_reference_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'shows data reference details' do
        get "/admin/data_references/#{data_ref.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['data_reference']['key']).to eq('test-tag')
        expect(json['data']['data_reference']['display_name']).to eq('Test Tag')
      end
    end
  end

  describe 'POST /admin/data_references' do
    context 'when user is admin' do
      before { sign_in admin_user }

      it 'creates a new data reference' do
        post '/admin/data_references',
             params: { data_reference: data_reference_attributes }.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['data_reference']['key']).to eq('test-tag')
        expect(json['message']).to eq('Data reference created successfully')
      end

      it 'validates required fields' do
        post '/admin/data_references',
             params: { data_reference: { key: 'test' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end
    end
  end

  describe 'PUT /admin/data_references/:id' do
    let!(:data_ref) { create(:data_reference, data_reference_attributes) }

    context 'AC-ADMIN-012: Dietary tag editing with cascade update' do
      before { sign_in admin_user }

      it 'updates the data reference' do
        put "/admin/data_references/#{data_ref.id}",
            params: { data_reference: { display_name: 'Updated Tag' } }.to_json,
            headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['data_reference']['display_name']).to eq('Updated Tag')
        expect(json['message']).to eq('Data reference updated successfully')

        data_ref.reload
        expect(data_ref.display_name).to eq('Updated Tag')
      end
    end
  end

  describe 'DELETE /admin/data_references/:id' do
    let!(:data_ref) { create(:data_reference, data_reference_attributes) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'deletes the data reference' do
        delete "/admin/data_references/#{data_ref.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['deleted']).to be true
        expect(json['message']).to eq('Data reference deleted successfully')

        expect(DataReference.find_by(id: data_ref.id)).to be_nil
      end
    end
  end

  describe 'POST /admin/data_references/:id/deactivate' do
    let!(:data_ref) { create(:data_reference, data_reference_attributes) }

    context 'AC-ADMIN-013: Tag deactivation' do
      before { sign_in admin_user }

      it 'deactivates the data reference' do
        post "/admin/data_references/#{data_ref.id}/deactivate", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['data_reference']['active']).to be false
        expect(json['message']).to eq('Data reference deactivated successfully')

        data_ref.reload
        expect(data_ref.active).to be false
      end
    end
  end

  describe 'POST /admin/data_references/:id/activate' do
    let!(:data_ref) { create(:data_reference, data_reference_attributes.merge(active: false)) }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'activates the data reference' do
        post "/admin/data_references/#{data_ref.id}/activate", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['data']['data_reference']['active']).to be true
        expect(json['message']).to eq('Data reference activated successfully')

        data_ref.reload
        expect(data_ref.active).to be true
      end
    end
  end
end
