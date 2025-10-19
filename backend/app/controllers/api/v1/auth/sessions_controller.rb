module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          render json: {
            success: true,
            message: 'Logged in successfully',
            data: {
              user: {
                id: resource.id,
                email: resource.email,
                role: resource.role
              }
            }
          }, status: :ok
        end

        def respond_to_on_destroy
          if request.headers['Authorization'].present?
            jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, Rails.application.credentials.devise_jwt_secret_key || ENV['DEVISE_JWT_SECRET_KEY']).first
            current_user = User.find(jwt_payload['sub'])
          end

          if current_user
            render json: {
              success: true,
              message: 'Logged out successfully'
            }, status: :ok
          else
            render json: {
              success: false,
              message: 'User not authenticated'
            }, status: :unauthorized
          end
        rescue JWT::DecodeError
          render json: {
            success: false,
            message: 'User not authenticated'
          }, status: :unauthorized
        end
      end
    end
  end
end
