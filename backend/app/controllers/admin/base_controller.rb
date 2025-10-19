module Admin
  class BaseController < Api::V1::BaseController
    before_action :authenticate_user!, unless: -> { request.format.html? }
    before_action :ensure_admin!

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
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

    private

    def ensure_admin!
      unless current_user&.admin?
        render json: {
          success: false,
          message: 'Admin access required'
        }, status: :forbidden
      end
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

    def record_invalid(exception)
      render_error(
        message: 'Validation failed',
        errors: exception.record.errors.full_messages
      )
    end
  end
end
