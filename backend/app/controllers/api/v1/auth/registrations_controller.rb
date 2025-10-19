module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              success: true,
              message: 'Signed up successfully',
              data: {
                user: {
                  id: resource.id,
                  email: resource.email,
                  role: resource.role
                }
              }
            }, status: :created
          else
            render json: {
              success: false,
              message: 'Registration failed',
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
