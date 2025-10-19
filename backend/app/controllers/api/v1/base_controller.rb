module Api
  module V1
    class BaseController < ActionController::API
      include Devise::Controllers::Helpers

      before_action :configure_permitted_parameters, if: :devise_controller?

      # Standard JSON response format
      def render_success(data:, message: nil, status: :ok)
        render json: {
          success: true,
          message: message,
          data: data
        }, status: status
      end

      def render_error(message:, errors: nil, status: :unprocessable_entity)
        render json: {
          success: false,
          message: message,
          errors: errors
        }, status: status
      end

      # Handle common exceptions
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing

      private

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
        devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
      end

      def record_not_found(exception)
        render_error(
          message: 'Record not found',
          errors: { detail: exception.message },
          status: :not_found
        )
      end

      def parameter_missing(exception)
        render_error(
          message: 'Required parameter missing',
          errors: { detail: exception.message },
          status: :bad_request
        )
      end
    end
  end
end
