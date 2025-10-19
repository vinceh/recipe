require 'rails_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json' } }

  describe 'POST /api/v1/auth/sign_up' do
    context 'AC-USER-001: User registration with email/password' do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a new user and returns JWT token in header' do
        post '/api/v1/auth',
             params: valid_params.to_json,
             headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['message']).to eq('Signed up successfully')
        expect(json['data']['user']['email']).to eq('newuser@example.com')
        expect(json['data']['user']['role']).to eq('user')

        # Check JWT token in Authorization header
        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end

      it 'sets default role to user' do
        post '/api/v1/auth',
             params: valid_params.to_json,
             headers: headers

        user = User.find_by(email: 'newuser@example.com')
        expect(user.role).to eq('user')
      end

      it 'returns error for invalid email' do
        post '/api/v1/auth',
             params: { user: { email: 'invalid', password: 'password123', password_confirmation: 'password123' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['errors']).to include('Email is invalid')
      end

      it 'returns error for missing password' do
        post '/api/v1/auth',
             params: { user: { email: 'newuser@example.com', password: '' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['errors']).to include("Password can't be blank")
      end

      it 'returns error for password confirmation mismatch' do
        post '/api/v1/auth',
             params: { user: { email: 'newuser@example.com', password: 'password123', password_confirmation: 'different' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['errors']).to include("Password confirmation doesn't match Password")
      end

      it 'returns error for duplicate email' do
        User.create!(email: 'existing@example.com', password: 'password123', password_confirmation: 'password123')

        post '/api/v1/auth',
             params: { user: { email: 'existing@example.com', password: 'password123', password_confirmation: 'password123' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['errors']).to include('Email has already been taken')
      end
    end
  end

  describe 'POST /api/v1/auth/sign_in' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }

    context 'AC-USER-002: User login with valid credentials' do
      it 'logs in and returns JWT token' do
        post '/api/v1/auth/sign_in',
             params: { user: { email: 'user@example.com', password: 'password123' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['success']).to be true
        expect(json['message']).to eq('Logged in successfully')
        expect(json['data']['user']['email']).to eq('user@example.com')
        expect(json['data']['user']['role']).to eq('user')

        # Check JWT token in Authorization header
        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end
    end

    context 'AC-USER-003: Login error handling' do
      it 'returns error for invalid email' do
        post '/api/v1/auth/sign_in',
             params: { user: { email: 'wrong@example.com', password: 'password123' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid Email or password.')
      end

      it 'returns error for invalid password' do
        post '/api/v1/auth/sign_in',
             params: { user: { email: 'user@example.com', password: 'wrongpassword' } }.to_json,
             headers: headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid Email or password.')
      end

      it 'does not reveal which field is incorrect' do
        # Test with wrong email
        post '/api/v1/auth/sign_in',
             params: { user: { email: 'wrong@example.com', password: 'password123' } }.to_json,
             headers: headers

        wrong_email_response = JSON.parse(response.body)['error']

        # Test with wrong password
        post '/api/v1/auth/sign_in',
             params: { user: { email: 'user@example.com', password: 'wrongpassword' } }.to_json,
             headers: headers

        wrong_password_response = JSON.parse(response.body)['error']

        # Both should return the same generic error message
        expect(wrong_email_response).to eq(wrong_password_response)
        expect(wrong_email_response).to eq('Invalid Email or password.')
      end
    end
  end

  describe 'DELETE /api/v1/auth/sign_out' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }
    let(:auth_token) do
      post '/api/v1/auth/sign_in',
           params: { user: { email: 'user@example.com', password: 'password123' } }.to_json,
           headers: headers
      response.headers['Authorization']
    end

    it 'logs out authenticated user' do
      delete '/api/v1/auth/sign_out',
             headers: headers.merge('Authorization' => auth_token)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['message']).to eq('Logged out successfully')
    end

    it 'returns error for unauthenticated user' do
      delete '/api/v1/auth/sign_out',
             headers: headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'JWT token usage' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }
    let(:auth_token) do
      post '/api/v1/auth/sign_in',
           params: { user: { email: 'user@example.com', password: 'password123' } }.to_json,
           headers: headers
      response.headers['Authorization']
    end

    it 'allows access to protected routes with valid token' do
      get '/api/v1/users/me/favorites',
          headers: headers.merge('Authorization' => auth_token)

      expect(response).to have_http_status(:ok)
    end

    it 'denies access to protected routes without token' do
      get '/api/v1/users/me/favorites',
          headers: headers

      expect(response).to have_http_status(:unauthorized)
    end

    it 'denies access with invalid token' do
      get '/api/v1/users/me/favorites',
          headers: headers.merge('Authorization' => 'Bearer invalid-token')

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
